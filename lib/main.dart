
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_style.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'signup_page.dart';
import 'store_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gnphutwiqnvhdypmetzc.supabase.co',
    publishableKey: 'sb_publishable_HdqwED3mFHF-tfUF-3qHvw_9_4-ww5r',
  );

  bool firebaseReady = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (error) {
    debugPrint(
      'Firebase is not set up for this platform. '
      'Using local data only. $error',
    );
  }

  runApp(MyApp(firebaseReady: firebaseReady));
}

class MyApp extends StatefulWidget {
  final bool firebaseReady;
  final SignUpRequest signUpRequest;

  const MyApp({
    super.key,
    required this.firebaseReady,
    this.signUpRequest = signUpWithSupabase,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Customer> accounts = [demoCustomer];
  Customer? currentCustomer;

  void logIn(Customer customer) {
    setState(() => currentCustomer = customer);
  }

  void signUp(Customer customer) {
    setState(() {
      accounts.add(customer);
      currentCustomer = customer;
    });
  }

  void updateCustomer(Customer updatedCustomer) {
    setState(() {
      final index = accounts.indexWhere(
        (account) => account.email == updatedCustomer.email,
      );

      if (index != -1) {
        accounts[index] = updatedCustomer;
      }

      currentCustomer = updatedCustomer;
    });
  }

  void logOut() {
    setState(() => currentCustomer = null);
  }

  @override
  Widget build(BuildContext context) {
    final customer = currentCustomer;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: storeName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          secondary: pink,
          secondaryContainer: blush,
          onSecondaryContainer: pink,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: darkText,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            side: BorderSide(color: borderColor),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: purple,
            minimumSize: const Size(0, 48),
            side: const BorderSide(color: pink),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: blush,
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: pink,
              width: 2,
            ),
          ),
        ),
      ),
      home: customer == null
          ? LoginPage(
              accounts: accounts,
              onLogIn: logIn,
              onSignUp: signUp,
              signUpRequest: widget.signUpRequest,
            )
          : MainPage(
              firebaseReady: widget.firebaseReady,
              customer: customer,
              onCustomerChanged: updateCustomer,
              onLogOut: logOut,
            ),
    );
  }
}

class MainPage extends StatefulWidget {
  final bool firebaseReady;
  final Customer customer;
  final ValueChanged<Customer> onCustomerChanged;
  final VoidCallback onLogOut;

  const MainPage({
    super.key,
    required this.firebaseReady,
    required this.customer,
    required this.onCustomerChanged,
    required this.onLogOut,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentTab = 0;
  bool isRefreshingPayments = false;

  final List<CartItem> cart = [];
  final List<StoreOrder> orders = [];

  late final AppLifecycleListener lifecycleListener;
  late final Timer paymentStatusTimer;

  @override
  void initState() {
    super.initState();
    lifecycleListener = AppLifecycleListener(
      onResume: () => _refreshPaymentStatuses(quiet: true),
    );
    paymentStatusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshPaymentStatuses(quiet: true),
    );
  }

  @override
  void dispose() {
    paymentStatusTimer.cancel();
    lifecycleListener.dispose();
    super.dispose();
  }

  void goToTab(int index) {
    setState(() => currentTab = index);

    if (index == 2) {
      _refreshPaymentStatuses();
    }
  }

  Future<void> _refreshPaymentStatuses({bool quiet = false}) async {
    if (isRefreshingPayments) return;

    final onlineOrders = orders
        .where(
          (order) =>
              order.externalId != null &&
              order.externalId!.isNotEmpty &&
              (!quiet || order.paymentStatus == 'Pending'),
        )
        .toList();

    if (onlineOrders.isEmpty) return;

    setState(() => isRefreshingPayments = true);

    try {
      final supabase = Supabase.instance.client;

      for (final order in onlineOrders) {
        final externalId = order.externalId!;

        final FunctionResponse response;

        try {
          response = await supabase.functions.invoke(
            'payment-status',
            body: {'external_id': externalId},
          );
        } on FunctionException catch (error) {
          final details = error.details;

          if (error.status == 404 &&
              details is Map &&
              details['error'] == 'Order not found') {
            debugPrint(
              'No Supabase order found for $externalId',
            );
            continue;
          }

          rethrow;
        }

        final data = response.data;
        final status = (data is Map ? data['status'] ?? '' : '')
            .toString()
            .toUpperCase();

        String newPaymentStatus;

        switch (status) {
          case 'PAID':
            newPaymentStatus = 'Paid';
            break;
          case 'FAILED':
          case 'EXPIRED':
          case 'CANCELLED':
          case 'CANCELED':
            newPaymentStatus = 'Failed';
            break;
          default:
            newPaymentStatus = 'Pending';
        }

        order.paymentStatus = newPaymentStatus;
      }

      if (mounted) {
        setState(() {});

        if (!quiet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment statuses refreshed.'),
            ),
          );
        }
      }
    } catch (error) {
      debugPrint('Payment status refresh failed: $error');

      if (mounted && !quiet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not refresh payment status. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isRefreshingPayments = false);
      }
    }
  }

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere(
        (item) => item.product == product,
      );

      if (index == -1) {
        cart.add(CartItem(product: product));
      } else {
        cart[index].quantity++;
      }
    });
  }

  void increaseQuantity(CartItem item) {
    setState(() => item.quantity++);
  }

  void decreaseQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  void removeFromCart(CartItem item) {
    setState(() => cart.remove(item));
  }

  Future<void> openCheckout() async {
    final order = await Navigator.push<StoreOrder>(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          customer: widget.customer,
          onCustomerChanged: widget.onCustomerChanged,
          cart: cart,
          orderNumber: 'SS-${1001 + orders.length}',
          firebaseReady: widget.firebaseReady,
        ),
      ),
    );

    if (order == null || !mounted) return;

    setState(() {
      orders.insert(0, order);
      cart.clear();
      currentTab = 2;
    });

    await _refreshPaymentStatuses();

    if (!mounted) return;

    final wantsToTrack = await showDialog<bool>(
      context: context,
      builder: (context) => OrderPlacedDialog(order: order),
    );

    if (wantsToTrack == true && mounted) {
      await openTracking(order);
    }
  }

  Future<void> openTracking(StoreOrder order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingPage(order: order),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void logOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'You have logged out. See you again, suki!',
        ),
      ),
    );

    widget.onLogOut();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = countItems(cart);

    final pages = [
      HomePage(
        customer: widget.customer,
        cart: cart,
        onAddToCart: addToCart,
        onOpenCart: () => goToTab(1),
      ),
      CartPage(
        cart: cart,
        onIncrease: increaseQuantity,
        onDecrease: decreaseQuantity,
        onRemove: removeFromCart,
        onCheckout: openCheckout,
        onShop: () => goToTab(0),
      ),
      OrdersPage(
        orders: orders,
        onOpenOrder: openTracking,
        onShop: () => goToTab(0),
      ),
      ProfilePage(
        customer: widget.customer,
        onCustomerChanged: widget.onCustomerChanged,
        orderCount: orders.length,
        onOpenOrders: () => goToTab(2),
        onLogOut: logOut,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: goToTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Home',
          ),
          NavigationDestination(
            icon: CartIcon(count: cartCount),
            selectedIcon: CartIcon(
              count: cartCount,
              filled: true,
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_style.dart';
import 'shipping_page.dart';
import 'store_data.dart';

class CheckoutPage extends StatefulWidget {
  final Customer customer;
  final ValueChanged<Customer> onCustomerChanged;
  final List<CartItem> cart;
  final String orderNumber;
  final bool firebaseReady;

  const CheckoutPage({
    super.key,
    required this.customer,
    required this.onCustomerChanged,
    required this.cart,
    required this.orderNumber,
    required this.firebaseReady,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Customer customer;
  String paymentMethod = 'Cash on Delivery';
  bool isPlacingOrder = false;

  bool get isCash => paymentMethod == 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
  }

  Future<void> changeShippingDetails() async {
    final updatedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (_) => ShippingDetailsPage(customer: customer),
      ),
    );

    if (updatedCustomer == null || !mounted) return;

    setState(() => customer = updatedCustomer);
    widget.onCustomerChanged(updatedCustomer);
  }

  Future<void> placeOrder() async {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() => isPlacingOrder = true);

    try {
      final subtotal = totalPrice(widget.cart);
      final total = subtotal + deliveryFee;

      final order = StoreOrder(
        orderNumber: widget.orderNumber,
        customer: customer,
        items: [
          for (final item in widget.cart)
            CartItem(
              product: item.product,
              quantity: item.quantity,
            ),
        ],
        paymentMethod: paymentMethod,
        paymentStatus: 'Pending',
        placedAt: DateTime.now(),
      );

      if (isCash) {
        await _saveToFirestoreSafely(order);

        if (!mounted) return;
        Navigator.pop(context, order);
        return;
      }

      final productNames = widget.cart
          .map((item) => '${item.quantity} x ${item.product.name}')
          .join(', ');

      final response =
          await Supabase.instance.client.functions.invoke(
        'create-invoice',
        body: {
          'product_name': productNames,
          'amount': total,
        },
      );

      final data = response.data;

      if (response.status < 200 ||
          response.status >= 300 ||
          data is! Map ||
          data['invoice_url'] is! String ||
          data['external_id'] is! String) {
        throw Exception(
          'Supabase did not return a valid invoice.',
        );
      }

      final invoiceUrl = data['invoice_url'] as String;
      final externalId = data['external_id'] as String;

      final uri = Uri.tryParse(invoiceUrl);

      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host != 'checkout-staging.xendit.co') {
        throw Exception('The returned test checkout URL is invalid.');
      }

      order.externalId = externalId;

      await _saveToFirestoreSafely(
        order,
        extraFields: {
          'xenditExternalId': externalId,
          'paymentStatus': 'PENDING',
        },
      );

      if (!mounted) return;

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!opened) {
        throw Exception('Could not open Xendit checkout.');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Xendit checkout opened. Payment is pending confirmation.',
          ),
        ),
      );

      Navigator.pop(context, order);
    } on FunctionException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not create payment invoice. '
            'Please try again. (${error.status})',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not place order: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isPlacingOrder = false);
      }
    }
  }

  Future<void> _saveToFirestoreSafely(
    StoreOrder order, {
    Map<String, dynamic> extraFields = const {},
  }) async {
    if (!widget.firebaseReady) return;

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': order.orderNumber,
        'customerName': order.customer.name,
        'customerEmail': order.customer.email,
        'customerPhone': order.customer.phone,
        'deliveryAddress': order.customer.address,
        'items': [
          for (final item in order.items)
            {
              'name': item.product.name,
              'price': item.product.price,
              'quantity': item.quantity,
            },
        ],
        'subtotal': order.subtotal,
        'deliveryFee': deliveryFee,
        'total': order.total,
        'paymentMethod': order.paymentMethod,
        'paymentStatus': order.paymentStatus,
        'shipmentStatus': order.shipmentStatus,
        'externalId': order.externalId,
        'createdAt': FieldValue.serverTimestamp(),
        ...extraFields,
      }).timeout(const Duration(seconds: 10));
    } catch (error) {
      debugPrint('Firestore order save failed: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Order could not be saved to Firebase. '
              'Payment status is managed separately by Supabase.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = totalPrice(widget.cart);
    final total = subtotal + deliveryFee;

    return PopScope(
      canPop: !isPlacingOrder,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionTitle('Delivery address'),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: pink,
                ),
                title: Text(
                  '${customer.name} · ${customer.phone}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                subtitle: Text(customer.address),
                trailing: TextButton(
                  onPressed:
                      isPlacingOrder ? null : changeShippingDetails,
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle('Payment method'),
            for (final method in paymentMethods)
              PaymentOption(
                method: method,
                selected: paymentMethod == method,
                onTap: isPlacingOrder
                    ? null
                    : () => setState(() => paymentMethod = method),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: blush,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: purple,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCash
                          ? 'Pay ${peso(total)} in cash when your order arrives.'
                          : 'You will continue to Xendit test checkout. '
                              'No real payment should be made in Test Mode.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle('Order summary'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final item in widget.cart)
                      InfoRow(
                        label:
                            '${item.quantity} × ${item.product.name}',
                        value: peso(item.total),
                      ),
                    const Divider(height: 24),
                    InfoRow(
                      label: 'Subtotal',
                      value: peso(subtotal),
                    ),
                    InfoRow(
                      label: 'Delivery fee',
                      value: peso(deliveryFee),
                    ),
                    const Divider(height: 24),
                    InfoRow(
                      label: 'Total',
                      value: peso(total),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isPlacingOrder ? null : placeOrder,
                child: Text(
                  isPlacingOrder
                      ? (isCash
                          ? 'Placing order...'
                          : 'Opening Xendit...')
                      : 'Place order',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentOption extends StatelessWidget {
  final String method;
  final bool selected;
  final VoidCallback? onTap;

  const PaymentOption({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCash = method == 'Cash on Delivery';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? pink : borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            isCash
                ? Icons.payments_outlined
                : Icons.account_balance_wallet_outlined,
            color: purple,
          ),
          title: Text(
            method,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          subtitle: Text(
            isCash
                ? 'Pay the rider when your order arrives'
                : 'Pay securely using Xendit checkout',
          ),
          trailing: Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? purple : greyText,
          ),
        ),
      ),
    );
  }
}

class OrderPlacedDialog extends StatelessWidget {
  final StoreOrder order;

  const OrderPlacedDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isCash = order.paymentMethod == 'Cash on Delivery';

    return AlertDialog(
      icon: const Icon(
        Icons.check_circle,
        color: green,
        size: 56,
      ),
      title: const Text('Order placed!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Salamat, suki! Order ${order.orderNumber} '
            'has been sent to the store.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          InfoRow(
            label: 'Total',
            value: peso(order.total),
            bold: true,
          ),
          InfoRow(
            label: 'Payment',
            value: order.paymentMethod,
          ),
          InfoRow(
            label: 'Payment status',
            value: order.paymentStatus,
          ),
          const SizedBox(height: 12),
          Text(
            isCash
                ? 'Please prepare cash for the rider.'
                : 'Payment is pending until confirmed by Xendit.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: greyText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Track order'),
        ),
      ],
    );
  }
}

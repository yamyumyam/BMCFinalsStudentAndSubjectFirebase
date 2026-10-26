const storeName = "Twiks & Kie's Sari-sari Store";

class Customer {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String address;

  const Customer({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
  });

  Customer withShippingDetails({
    required String newPhone,
    required String newAddress,
  }) {
    return Customer(
      name: name,
      phone: newPhone,
      email: email,
      password: password,
      address: newAddress,
    );
  }
}

String? mobileNumberError(String? value) {
  final phone = (value ?? '').replaceAll(' ', '');

  if (phone.length != 11 ||
      !phone.startsWith('09') ||
      int.tryParse(phone) == null) {
    return 'Enter an 11-digit mobile number, like 09171234567.';
  }

  return null;
}

const demoCustomer = Customer(
  name: 'Maria Santos',
  phone: '09171234567',
  email: 'maria.santos@email.com',
  password: 'sari1234',
  address: '123 Sampaguita St., Brgy. San Isidro, Quezon City',
);

const deliveryFee = 25.0;

const categories = ['All', 'Snacks', 'Drinks', 'Pantry', 'Household'];

const paymentMethods = ['Cash on Delivery', 'GCash', 'Maya'];

class Product {
  final String name;
  final String category;
  final double price;
  final String size;
  final String image;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.size,
    required this.image,
  });
}

const products = [
  Product(
    name: 'Piattos Cheese',
    category: 'Snacks',
    price: 20,
    size: '40 g',
    image: 'assets/products/piattos_cheese.png',
  ),
  Product(
    name: 'SkyFlakes Crackers',
    category: 'Snacks',
    price: 8,
    size: '25 g',
    image: 'assets/products/skyflakes_crackers.png',
  ),
  Product(
    name: 'Boy Bawang Cornick',
    category: 'Snacks',
    price: 20,
    size: '100 g',
    image: 'assets/products/boy_bawang_cornick.png',
  ),
  Product(
    name: 'Choco Mucho Bar',
    category: 'Snacks',
    price: 10,
    size: '1 bar',
    image: 'assets/products/choco_mucho_bar.png',
  ),
  Product(
    name: 'Coca-Cola',
    category: 'Drinks',
    price: 85,
    size: '1.5 L',
    image: 'assets/products/coca_cola.png',
  ),
  Product(
    name: 'C2 Green Tea Apple',
    category: 'Drinks',
    price: 30,
    size: '500 ml',
    image: 'assets/products/c2_green_tea_apple.png',
  ),
  Product(
    name: 'Kopiko Brown Coffee',
    category: 'Drinks',
    price: 10,
    size: '1 sachet',
    image: 'assets/products/kopiko_brown_coffee.png',
  ),
  Product(
    name: 'Mineral Water',
    category: 'Drinks',
    price: 15,
    size: '500 ml',
    image: 'assets/products/mineral_water.png',
  ),
  Product(
    name: 'Lucky Me! Pancit Canton',
    category: 'Pantry',
    price: 16,
    size: '60 g',
    image: 'assets/products/lucky_me_pancit_canton.png',
  ),
  Product(
    name: 'Century Tuna Flakes',
    category: 'Pantry',
    price: 38,
    size: '155 g',
    image: 'assets/products/century_tuna_flakes.png',
  ),
  Product(
    name: 'Fresh Eggs',
    category: 'Pantry',
    price: 54,
    size: '6 pcs',
    image: 'assets/products/fresh_eggs.png',
  ),
  Product(
    name: 'Bear Brand Milk',
    category: 'Pantry',
    price: 14,
    size: '33 g',
    image: 'assets/products/bear_brand_milk.png',
  ),
  Product(
    name: 'Safeguard Bar Soap',
    category: 'Household',
    price: 28,
    size: '60 g',
    image: 'assets/products/safeguard_bar_soap.png',
  ),
  Product(
    name: 'Surf Powder Detergent',
    category: 'Household',
    price: 10,
    size: '65 g',
    image: 'assets/products/surf_powder_detergent.png',
  ),
  Product(
    name: 'Joy Dishwashing Liquid',
    category: 'Household',
    price: 10,
    size: '20 ml',
    image: 'assets/products/joy_dishwashing_liquid.png',
  ),
  Product(
    name: 'Colgate Toothpaste',
    category: 'Household',
    price: 12,
    size: '22 ml',
    image: 'assets/products/colgate_toothpaste.png',
  ),
];

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class TrackingStep {
  final String title;
  final String message;
  final String emoji;

  const TrackingStep(this.title, this.message, this.emoji);
}

const trackingSteps = [
  TrackingStep(
    'Order placed',
    'The store received your order.',
    '🧾',
  ),
  TrackingStep(
    'Preparing your order',
    'Twiks and Kie is packing your items.',
    '🧺',
  ),
  TrackingStep(
    'Out for delivery',
    'Your rider is on the way.',
    '🛵',
  ),
  TrackingStep(
    'Delivered',
    'Your order has arrived. Salamat, suki!',
    '🎉',
  ),
];

class StoreOrder {
  final String orderNumber;
  final Customer customer;
  final List<CartItem> items;
  final String paymentMethod;

  String paymentStatus;

  String? externalId;

  final DateTime placedAt;
  int step = 0;

  StoreOrder({
    required this.orderNumber,
    required this.customer,
    required this.items,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.placedAt,
    this.externalId,
  });

  double get subtotal => totalPrice(items);

  double get total => subtotal + deliveryFee;

  String get shipmentStatus => trackingSteps[step].title;

  bool get isDelivered => step == trackingSteps.length - 1;

  void moveToNextStep() {
    if (isDelivered) return;

    step++;

    if (isDelivered && paymentMethod == 'Cash on Delivery') {
      paymentStatus = 'Paid';
    }
  }
}

int countItems(List<CartItem> items) {
  int count = 0;

  for (final item in items) {
    count += item.quantity;
  }

  return count;
}

double totalPrice(List<CartItem> items) {
  double total = 0;

  for (final item in items) {
    total += item.total;
  }

  return total;
}

String peso(double amount) => '₱${amount.toStringAsFixed(2)}';

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final amPm = date.hour < 12 ? 'AM' : 'PM';

  return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute $amPm';
}

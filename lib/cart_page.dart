import 'package:flutter/material.dart';

import 'app_style.dart';
import 'store_data.dart';

class CartPage extends StatelessWidget {
  final List<CartItem> cart;
  final ValueChanged<CartItem> onIncrease;
  final ValueChanged<CartItem> onDecrease;
  final ValueChanged<CartItem> onRemove;
  final VoidCallback onCheckout;
  final VoidCallback onShop;

  const CartPage({
    super.key,
    required this.cart,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onCheckout,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My cart')),
        body: EmptyMessage(
          icon: Icons.shopping_bag_outlined,
          title: 'Your cart is empty',
          message: 'Add snacks, drinks, and everyday needs from the store.',
          buttonText: 'Start shopping',
          onPressed: onShop,
        ),
      );
    }

    final subtotal = totalPrice(cart);

    return Scaffold(
      appBar: AppBar(title: const Text('My cart')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final item in cart)
            CartItemCard(
              item: item,
              onIncrease: () => onIncrease(item),
              onDecrease: () => onDecrease(item),
              onRemove: () => onRemove(item),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(label: 'Items', value: '${countItems(cart)}'),
                  InfoRow(label: 'Subtotal', value: peso(subtotal), bold: true),
                  const SizedBox(height: 6),
                  Text(
                    'A delivery fee of ${peso(deliveryFee)} will be added at checkout.',
                    style: const TextStyle(fontSize: 12, color: greyText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(fontSize: 12, color: greyText),
                    ),
                    Text(
                      peso(subtotal),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: pink,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onCheckout,
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: blush,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ProductImage(product.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.size} · ${peso(product.price)} each',
                      style: const TextStyle(fontSize: 12, color: greyText),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: onDecrease,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: onIncrease,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline, color: greyText),
                  ),
                  Text(
                    peso(item.total),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

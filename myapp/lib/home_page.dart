
import 'package:flutter/material.dart';

import 'app_style.dart';
import 'store_data.dart';

class HomePage extends StatefulWidget {
  final Customer customer;
  final List<CartItem> cart;
  final ValueChanged<Product> onAddToCart;
  final VoidCallback onOpenCart;

  const HomePage({
    super.key,
    required this.customer,
    required this.cart,
    required this.onAddToCart,
    required this.onOpenCart,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = '';
  String selectedCategory = 'All';

  int quantityInCart(Product product) {
    for (final item in widget.cart) {
      if (item.product == product) return item.quantity;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final shownProducts = products.where((product) {
      final matchesCategory = selectedCategory == 'All' ||
          product.category == selectedCategory;

      final matchesSearch = product.name.toLowerCase().contains(
            searchText.toLowerCase(),
          );

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: blush,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/products/sari_sari_store.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.storefront,
                          color: purple,
                          size: 30,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Twiks & Kie's Sari-Sari Store",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: pink,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Deliver to ${widget.customer.address}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: greyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onOpenCart,
                  color: purple,
                  icon: CartIcon(
                    count: countItems(widget.cart),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              onChanged: (value) {
                setState(() => searchText = value);
              },
              decoration: const InputDecoration(
                hintText: 'Search snacks, drinks, and more',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 90,
                child: Image.asset(
                  'assets/products/store_banner.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            const SectionTitle('Categories'),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (value) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: blush,
                        side: BorderSide(
                          color: selectedCategory == category
                              ? pink
                              : borderColor,
                        ),
                        labelStyle: TextStyle(
                          color: selectedCategory == category
                              ? purple
                              : greyText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: SectionTitle('Products'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${shownProducts.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: greyText,
                    ),
                  ),
                ),
              ],
            ),

            if (shownProducts.isEmpty)
              const EmptyMessage(
                icon: Icons.search_off,
                title: 'No products found',
                message: 'Try a different word or category.',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shownProducts.length,
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 262,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final product = shownProducts[index];

                  return ProductCard(
                    product: product,
                    quantityInCart: quantityInCart(product),
                    onAdd: () => widget.onAddToCart(product),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantityInCart;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantityInCart,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: blush,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ProductImage(product.image),
                      ),
                    ),
                    if (quantityInCart > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: pink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$quantityInCart in cart',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              product.size,
              style: const TextStyle(
                fontSize: 12,
                color: greyText,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              peso(product.price),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pink,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: blush,
                  foregroundColor: purple,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

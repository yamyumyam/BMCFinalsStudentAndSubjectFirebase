import 'package:flutter/material.dart';

import 'app_style.dart';
import 'shipping_page.dart';
import 'store_data.dart';

class ProfilePage extends StatelessWidget {
  final Customer customer;
  final ValueChanged<Customer> onCustomerChanged;
  final int orderCount;
  final VoidCallback onOpenOrders;
  final VoidCallback onLogOut;

  const ProfilePage({
    super.key,
    required this.customer,
    required this.onCustomerChanged,
    required this.orderCount,
    required this.onOpenOrders,
    required this.onLogOut,
  });

  Future<void> editShippingDetails(BuildContext context) async {
    final updatedCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => ShippingDetailsPage(customer: customer),
      ),
    );
    if (updatedCustomer != null) {
      onCustomerChanged(updatedCustomer);
    }
  }

  Future<void> confirmLogOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to place orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onLogOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: storeGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 32, color: purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: const TextStyle(color: lightText),
                      ),
                      Text(
                        customer.email,
                        style: const TextStyle(color: lightText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Shipping details'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_outlined, color: pink),
              title: Text(
                'Contact: ${customer.phone}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              subtitle: Text(customer.address),
              trailing: TextButton(
                onPressed: () => editShippingDetails(context),
                child: const Text('Edit'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('My account'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  onTap: onOpenOrders,
                  leading: const Icon(
                    Icons.receipt_long_outlined,
                    color: purple,
                  ),
                  title: const Text(
                    'Order history',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  subtitle: Text(
                    orderCount == 1 ? '1 order' : '$orderCount orders',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: greyText),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: purple,
                  ),
                  title: Text(
                    'Payment options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  subtitle: Text('Cash on Delivery, GCash, Maya'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => confirmLogOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

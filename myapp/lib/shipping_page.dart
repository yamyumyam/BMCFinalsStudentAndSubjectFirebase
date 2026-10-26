import 'package:flutter/material.dart';

import 'app_style.dart';
import 'store_data.dart';

class ShippingDetailsPage extends StatefulWidget {
  final Customer customer;

  const ShippingDetailsPage({super.key, required this.customer});

  @override
  State<ShippingDetailsPage> createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.customer.phone;
    addressController.text = widget.customer.address;
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    final updatedCustomer = widget.customer.withShippingDetails(
      newPhone: phoneController.text.replaceAll(' ', ''),
      newAddress: addressController.text.trim(),
    );

    Navigator.pop(context, updatedCustomer);
  }

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Where should we deliver?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your rider will use these details for your next orders.',
                  style: TextStyle(color: greyText),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                    hintText: '09xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: mobileNumberError,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: addressController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                    hintText: 'House no., street, barangay, city',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your delivery address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: save,
                    child: const Text('Save shipping details'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

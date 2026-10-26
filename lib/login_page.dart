import 'package:flutter/material.dart';

import 'app_style.dart';
import 'signup_page.dart';
import 'store_data.dart';

class LoginPage extends StatefulWidget {
  final List<Customer> accounts;
  final ValueChanged<Customer> onLogIn;
  final ValueChanged<Customer> onSignUp;
  final SignUpRequest signUpRequest;

  const LoginPage({
    super.key,
    required this.accounts,
    required this.onLogIn,
    required this.onSignUp,
    this.signUpRequest = signUpWithSupabase,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  String errorMessage = '';

  void useDemoAccount() {
    emailController.text = demoCustomer.email;
    passwordController.text = demoCustomer.password;
    setState(() => errorMessage = '');
  }

  void logIn() {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    for (final account in widget.accounts) {
      if (account.email == email && account.password == password) {
        widget.onLogIn(account);
        return;
      }
    }

    setState(() => errorMessage = 'Wrong email or password. Please try again.');
  }

  Future<void> openSignUp() async {
    final newCustomer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(
          accounts: widget.accounts,
          signUpRequest: widget.signUpRequest,
        ),
      ),
    );
    if (newCustomer != null) {
      widget.onSignUp(newCustomer);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: blush,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storefront, color: purple),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: storeGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your neighborhood store, delivered.',
                        style: TextStyle(
                          fontSize: 24,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Snacks, drinks, and everyday needs from your suki store.',
                        style: TextStyle(fontSize: 13, color: lightText),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          for (final product in products.take(4))
                            Container(
                              width: 48,
                              height: 48,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ProductImage(product.image),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome back, suki!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Log in to start ordering.',
                  style: TextStyle(color: greyText),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password.';
                    }
                    return null;
                  },
                ),
                if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(errorMessage, style: const TextStyle(color: red)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: logIn,
                    child: const Text('Log in'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  decoration: BoxDecoration(
                    color: blush,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Just trying the app?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Demo account: ${demoCustomer.email}\nPassword: ${demoCustomer.password}',
                        style: const TextStyle(fontSize: 12, color: greyText),
                      ),
                      TextButton(
                        onPressed: useDemoAccount,
                        child: const Text('Use demo account'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'New to the store?',
                      style: TextStyle(color: greyText),
                    ),
                    TextButton(
                      onPressed: openSignUp,
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

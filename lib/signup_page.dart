import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_style.dart';
import 'store_data.dart';

typedef SignUpRequest = Future<AuthResponse> Function({
  required String email,
  required String password,
  required Map<String, dynamic> data,
});

Future<AuthResponse> signUpWithSupabase({
  required String email,
  required String password,
  required Map<String, dynamic> data,
}) async {
  final auth = Supabase.instance.client.auth;
  final response = await auth.signUp(
    email: email,
    password: password,
    data: data,
  );

  if (response.session != null) {
    try {
      await auth.signOut(scope: SignOutScope.local);
    } catch (error) {
      debugPrint('Supabase sign-out after sign-up failed: $error');
    }
  }

  return response;
}

class SignUpPage extends StatefulWidget {
  final List<Customer> accounts;
  final SignUpRequest signUpRequest;

  const SignUpPage({
    super.key,
    required this.accounts,
    this.signUpRequest = signUpWithSupabase,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();
  bool hidePassword = true;
  bool isCreatingAccount = false;
  String errorMessage = '';

  Future<void> createAccount() async {
    if (isCreatingAccount || !formKey.currentState!.validate()) return;

    final customer = Customer(
      name: nameController.text.trim(),
      phone: phoneController.text.replaceAll(' ', ''),
      email: emailController.text.trim().toLowerCase(),
      password: passwordController.text,
      address: addressController.text.trim(),
    );

    FocusScope.of(context).unfocus();
    setState(() {
      isCreatingAccount = true;
      errorMessage = '';
    });

    try {
      final response = await widget.signUpRequest(
        email: customer.email,
        password: customer.password,
        data: {
          'full_name': customer.name,
          'mobile_number': customer.phone,
          'delivery_address': customer.address,
        },
      );

      if (!mounted) return;

      final user = response.user;

      if (user == null) {
        setState(() {
          errorMessage = 'Your account was not created. Please try again.';
        });
        return;
      }

      if (user.identities != null && user.identities!.isEmpty) {
        setState(() {
          errorMessage = 'This email already has an account. Please log in.';
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.emailConfirmedAt == null
                ? 'Account created! Check your email to confirm it.'
                : 'Account created!',
          ),
        ),
      );
      Navigator.pop(context, customer);
    } on AuthException catch (error) {
      debugPrint('Supabase sign-up failed: ${error.code} ${error.message}');

      if (mounted) {
        setState(() => errorMessage = signUpErrorMessage(error));
      }
    } catch (error) {
      debugPrint('Sign-up failed: $error');

      if (mounted) {
        setState(() {
          errorMessage = 'Your account was not created. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => isCreatingAccount = false);
      }
    }
  }

  String signUpErrorMessage(AuthException error) {
    if (error is AuthRetryableFetchException) {
      return 'Could not reach the server. Check your internet connection '
          'and try again.';
    }

    if (error.message.contains('Database error saving new user')) {
      return 'We could not save your profile, so your account was not '
          'created. Please try again.';
    }

    switch (error.code) {
      case 'user_already_exists':
      case 'email_exists':
        return 'This email already has an account. Please log in.';
      case 'weak_password':
        return 'Please choose a stronger password.';
      case 'over_email_send_rate_limit':
        return 'Too many sign-up attempts. Please wait a few minutes '
            'and try again.';
      case 'email_address_not_authorized':
        return 'We could not send a confirmation email to this address. '
            'Please try again later.';
    }

    return 'Your account was not created. Please try again.';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isCreatingAccount,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign up')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join your suki store',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create an account to order snacks, drinks, and everyday needs.',
                    style: TextStyle(color: greyText),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'e.g. Juan dela Cruz',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your full name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      hintText: '09xxxxxxxxx',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: mobileNumberError,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = (value ?? '').trim().toLowerCase();
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Enter a valid email address.';
                      }
                      for (final account in widget.accounts) {
                        if (account.email == email) {
                          return 'This email already has an account. Please log in.';
                        }
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
                      hintText: 'At least 8 characters',
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
                      if (value == null || value.length < 8) {
                        return 'Use at least 8 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: hidePassword,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: addressController,
                    minLines: 1,
                    maxLines: 2,
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
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(errorMessage, style: const TextStyle(color: red)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isCreatingAccount ? null : createAccount,
                      child: Text(
                        isCreatingAccount
                            ? 'Creating account...'
                            : 'Create account',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: greyText),
                      ),
                      TextButton(
                        onPressed: isCreatingAccount
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Log in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

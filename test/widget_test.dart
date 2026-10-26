import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/main.dart';

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> tapOnScreen(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> logInWithDemoAccount(WidgetTester tester) async {
  await tapOnScreen(tester, find.text('Use demo account'));
  await tapOnScreen(tester, find.widgetWithText(FilledButton, 'Log in'));
}

User fakeSupabaseUser({required List<UserIdentity> identities}) {
  return User(
    id: '11111111-1111-1111-1111-111111111111',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: '2026-10-26T00:00:00Z',
    identities: identities,
  );
}

const fakeEmailIdentity = UserIdentity(
  id: '11111111-1111-1111-1111-111111111111',
  userId: '11111111-1111-1111-1111-111111111111',
  identityData: {},
  identityId: '22222222-2222-2222-2222-222222222222',
  provider: 'email',
  createdAt: '2026-10-26T00:00:00Z',
  lastSignInAt: '2026-10-26T00:00:00Z',
);

Future<void> fillSignUpForm(WidgetTester tester) async {
  await tapOnScreen(tester, find.text('Create an account'));
  expect(find.text('Join your suki store'), findsOneWidget);

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Full name'),
    'Juan dela Cruz',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Mobile number'),
    '09181234567',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    'juan@email.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    'tindahan1',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirm password'),
    'tindahan1',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Delivery address'),
    '45 Mabini St., Marikina City',
  );
  await tapOnScreen(
    tester,
    find.widgetWithText(FilledButton, 'Create account'),
  );
}

void main() {
  testWidgets('App opens on the Login page and rejects a wrong password', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp(firebaseReady: false));

    expect(find.text('Welcome back, suki!'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'maria.santos@email.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrongpass',
    );
    await tapOnScreen(tester, find.widgetWithText(FilledButton, 'Log in'));

    expect(
      find.text('Wrong email or password. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('Sign up creates an account and opens the Home page', (
    tester,
  ) async {
    usePhoneScreen(tester);

    String? sentEmail;
    String? sentPassword;
    Map<String, dynamic>? sentProfile;

    await tester.pumpWidget(
      MyApp(
        firebaseReady: false,
        signUpRequest:
            ({
              required String email,
              required String password,
              required Map<String, dynamic> data,
            }) async {
              sentEmail = email;
              sentPassword = password;
              sentProfile = data;
              return AuthResponse(
                user: fakeSupabaseUser(identities: [fakeEmailIdentity]),
              );
            },
      ),
    );

    await fillSignUpForm(tester);

    expect(sentEmail, 'juan@email.com');
    expect(sentPassword, 'tindahan1');
    expect(sentProfile, {
      'full_name': 'Juan dela Cruz',
      'mobile_number': '09181234567',
      'delivery_address': '45 Mabini St., Marikina City',
    });

    expect(
      find.text('Deliver to 45 Mabini St., Marikina City'),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Juan dela Cruz'), findsOneWidget);
  });

  testWidgets('Sign up stays on the form when the profile cannot be saved', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MyApp(
        firebaseReady: false,
        signUpRequest:
            ({
              required String email,
              required String password,
              required Map<String, dynamic> data,
            }) async {
              throw const AuthApiException(
                'Database error saving new user',
                statusCode: '500',
                code: 'unexpected_failure',
              );
            },
      ),
    );

    await fillSignUpForm(tester);

    expect(
      find.text(
        'We could not save your profile, so your account was not '
        'created. Please try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Join your suki store'), findsOneWidget);
    expect(find.text('Deliver to 45 Mabini St., Marikina City'), findsNothing);
  });

  testWidgets('Sign up rejects an email that is already registered', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MyApp(
        firebaseReady: false,
        signUpRequest:
            ({
              required String email,
              required String password,
              required Map<String, dynamic> data,
            }) async {
              return AuthResponse(user: fakeSupabaseUser(identities: []));
            },
      ),
    );

    await fillSignUpForm(tester);

    expect(
      find.text('This email already has an account. Please log in.'),
      findsOneWidget,
    );
    expect(find.text('Join your suki store'), findsOneWidget);
  });

  testWidgets('Search shows only matching products', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp(firebaseReady: false));
    await logInWithDemoAccount(tester);

    await tester.enterText(find.byType(TextField), 'tuna');
    await tester.pump();

    expect(find.text('Century Tuna Flakes'), findsOneWidget);
    expect(find.text('Coca-Cola'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Shipping details can be changed at checkout', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp(firebaseReady: false));
    await logInWithDemoAccount(tester);

    await tapOnScreen(tester, find.text('Add to cart').first);
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contact number'),
      '0912345',
    );
    await tapOnScreen(tester, find.text('Save shipping details'));
    expect(
      find.text('Enter an 11-digit mobile number, like 09171234567.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contact number'),
      '09998887777',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Delivery address'),
      '7 Rizal Ave., Pasig City',
    );
    await tapOnScreen(tester, find.text('Save shipping details'));

    expect(find.text('Maria Santos · 09998887777'), findsOneWidget);
    expect(find.text('7 Rizal Ave., Pasig City'), findsOneWidget);

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Contact: 09998887777'), findsOneWidget);
  });

  testWidgets('A product can be added, ordered, and tracked', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp(firebaseReady: false));
    await logInWithDemoAccount(tester);

    expect(find.text("Aling Nena's Sari-Sari Store"), findsOneWidget);

    await tapOnScreen(tester, find.text('Add to cart').first);
    expect(find.text('1 in cart'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    expect(find.text('Order placed!'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Track order'));
    await tester.pumpAndSettle();
    expect(find.text('Order SS-1001'), findsOneWidget);

    await tester.tap(find.text('Simulate next status (demo)'));
    await tester.pump();
    expect(find.text('Preparing your order'), findsWidgets);
    expect(find.text('Now'), findsOneWidget);
  });

  testWidgets('Log out goes back to the Login page', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp(firebaseReady: false));
    await logInWithDemoAccount(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    final logOutButton = find.widgetWithText(OutlinedButton, 'Log out');
    await tester.scrollUntilVisible(logOutButton, 200);
    await tapOnScreen(tester, logOutButton);
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, suki!'), findsOneWidget);
  });
}

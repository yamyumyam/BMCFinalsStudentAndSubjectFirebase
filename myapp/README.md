# Twiks & Kie's Sari-sari Store

A shopping app for Android phones made for a neighborhood sari-sari store.
Customers can browse snacks, drinks, pantry items, and household goods, add them
to a cart, check out with Cash on Delivery, GCash, or Maya, and track their order
until it arrives.

## Features

- Log in, sign up, or try the app with a ready-made demo account
- Search products and filter them by category
- Cart with quantity controls and a running subtotal
- Checkout with an editable delivery address and a choice of payment method
- Online payment (GCash / Maya) through Xendit **test mode**: no real money is charged
- Order history with payment status and step-by-step shipment tracking
- Profile page for updating your contact number and delivery address

---

## Part 1: Installing the app on your Android phone

The app is installed from an **APK file** (`app-release.apk`), not from the
Google Play Store.

### Requirements

- An Android phone running **Android 7.0 or newer**
- The APK file `app-release.apk`
  - **Download link:** _([G-Drive](https://drive.google.com/drive/folders/197ujuOk0_HJOmgKDDVkiGv1dD9Xbbe8Y?usp=sharing))_
  - Or copy it from the project folder: `build/app/outputs/flutter-apk/app-release.apk`
- An internet connection (needed for online payments)

### Step 1: Get the APK file on your phone

Use whichever is easiest:

- **From the download link:** open the link on your phone and download
  `app-release.apk`. It is saved to your **Downloads** folder.
- **From a computer (USB cable):** connect your phone, choose **File transfer**
  on the phone, then copy `app-release.apk` into the phone's **Download** folder.
- **Sent by a groupmate:** save the file from Messenger, Google Drive, email, etc.

### Step 2: Open the APK file

1. Open your phone's **Files** (or **My Files**) app and go to **Downloads**.
   You can also tap the finished download in your browser's notification.
2. Tap **app-release.apk**.

### Step 3: Allow installing from unknown sources

Because the app is not from the Play Store, Android asks for permission the
first time:

1. When you see *"For your security, your phone is not allowed to install
   unknown apps from this source"*, tap **Settings**.
2. Turn on **Allow from this source**.
3. Press **Back** to return to the installer.

> The exact wording differs between phone brands (Samsung, Xiaomi, Oppo, etc.),
> but the steps are the same.

### Step 4: Install the app

1. Tap **Install**.
2. If **Google Play Protect** shows a warning, tap **More details** →
   **Install anyway**. This appears for any app that isn't from the Play Store.
3. Wait for *"App installed"*, then tap **Open**.

### Step 5: Find the app later

The app appears on your home screen or app drawer as **myapp**. Tap it to open
the store.

### Updating to a newer version

Install the new `app-release.apk` the same way. If you see *"App not
installed"*, uninstall the old **myapp** first (long-press the icon →
**Uninstall**), then install the new APK.

---

## Part 2: How to use the app

### Step 1: Log in or create an account

**Option A: Use the demo account (quickest)**

1. On the login screen, find the **"Just trying the app?"** box.
2. Tap **Use demo account**. This fills in the email and password for you:
   - Email: `maria.santos@email.com`
   - Password: `sari1234`
3. Tap **Log in**.

**Option B: Create your own account**

1. Tap **Create an account** at the bottom of the login screen.
2. Fill in the form:
   - **Full name**
   - **Mobile number**: 11 digits starting with `09` (e.g. `09171234567`)
   - **Email**: must not already be registered
   - **Password**: at least 8 characters, entered twice to confirm
   - **Delivery address**: house no., street, barangay, city
3. Tap **Create account**. You are logged in right away.

### Step 2: Browse and add products

1. The **Home** tab shows all products. Your delivery address appears at the top.
2. To find something:
   - Type in the **search bar** (e.g. "coffee"), or
   - Tap a **category**: All, Snacks, Drinks, Pantry, or Household.
3. Tap **Add to cart** on a product. Tap it again to add more.
   A pink **"N in cart"** badge shows how many you've added.
4. The cart icon at the top right (and on the **Cart** tab) shows your total item count.

### Step 3: Review your cart

1. Tap the **Cart** tab, or the cart icon on the Home screen.
2. For each item you can:
   - Tap **+** to add one more
   - Tap **−** to remove one (when only one is left, this removes the item)
   - Tap the **trash icon** to remove the item completely
3. Check the **Subtotal** at the bottom. A **₱25.00 delivery fee** is added at checkout.
4. Tap **Checkout**.

### Step 4: Check out

1. **Delivery address:** confirm your name, number, and address.
   To change them, tap **Change**, edit the details, then tap
   **Save shipping details**. The new details are also saved to your profile.
2. **Payment method:** choose one:
   - **Cash on Delivery**: pay the rider when your order arrives
   - **GCash** or **Maya**: pay online through the Xendit test checkout
3. **Order summary:** check your items, the subtotal, the ₱25.00 delivery fee,
   and the **Total**.
4. Tap **Place order**.

### Step 5: Complete the payment

**If you chose Cash on Delivery**

1. An **"Order placed!"** message appears with your order number (e.g. `SS-1001`).
2. Prepare the exact amount for the rider. The payment status shows
   **Pending** until the order is delivered, then changes to **Paid**.

**If you chose GCash or Maya**

1. The **Xendit test checkout** page opens in your phone's browser.
2. Follow the instructions on that page to complete the test payment.
   This is **test mode**, so do not use real account details or money.
3. Return to the app with the **Back** button or from **Recent apps**.
   Your order appears under **Orders** with payment status **Pending**.
4. The app checks for payment updates every few seconds, whenever you return to
   the app, and whenever you open the **Orders** tab. Once Xendit confirms the
   payment, the status changes to:
   - 🟢 **Paid**: payment received
   - 🔴 **Failed**: the payment failed, expired, or was cancelled
   - 🟠 **Pending**: still waiting for confirmation

### Step 6: Track your order

1. In the **"Order placed!"** message, tap **Track order**. Or open the
   **Orders** tab and tap any order card.
2. The tracking page shows where your order is:

   | Step | Status               | Meaning                               |
   | ---- | ---------------------| ------------------------------------- |
   | 1    | Order placed         | The store received your order.        |
   | 2    | Preparing your order | Twiks and Kie is packing your items.  |
   | 3    | Out for delivery     | Your rider is on the way.             |
   | 4    | Delivered            | Your order has arrived.               |

3. **Demo only:** tap **Simulate next status (demo)** to move the order to the
   next step. There is no real rider, so this shows how tracking works.
4. Scroll down to see the order details, payment status, and delivery address.

### Step 7: Manage your profile and log out

1. Open the **Profile** tab to see your name, mobile number, and email.
2. Under **Shipping details**, tap **Edit** to update your contact number or
   delivery address. These are used for your next orders.
3. Tap **Order history** to jump to your orders.
4. Tap **Log out**, then confirm.

---

## Good to know

- **Data is not saved permanently.** Accounts, carts, and orders are stored
  only while the app is open. Closing the app (swiping it away from Recent
  apps) or restarting your phone clears them. The demo account always stays
  available.
- **Logging out clears your cart and order list.** Your account still works
  until the app is closed.
- **Payments are in test mode.** GCash and Maya go through Xendit's test
  environment, and no real money is charged.
- **Order tracking is simulated.** Order status only moves forward when you tap
  **Simulate next status (demo)**.

## Troubleshooting

| Problem | What to do |
| ------- | ---------- |
| Installation is blocked | Allow installing unknown apps for the app you opened the APK from (see Part 1, Step 3). |
| "App not installed" | Uninstall the old **myapp** first, then install the APK again. Also check that your phone runs Android 7.0 or newer and has enough free storage. |
| Can't find the app after installing | Look for **myapp** in your app drawer. |
| "Wrong email or password" | Check the spelling, or use **Use demo account**. If you signed up earlier, your account was cleared when the app closed, so sign up again. |
| "This email already has an account" | Log in with that email instead, or use a different email. |
| Mobile number is rejected | Enter exactly 11 digits starting with `09`, e.g. `09171234567`. |
| "Could not create payment invoice" | Check your internet connection and try again, or choose **Cash on Delivery**. |
| Payment status stays **Pending** | Make sure you finished the payment on the Xendit page, then open the **Orders** tab to refresh. |

---

## For developers

### Building the APK

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(Dart 3.13.4 or newer). In this `myapp` folder, run:

```bash
flutter pub get
flutter build apk --release
```

The APK is saved to `build/app/outputs/flutter-apk/app-release.apk` (a copy
is also at `build/app/outputs/apk/release/app-release.apk`). Share this file
or upload it to Google Drive.

To make smaller APKs (one per phone processor type), run
`flutter build apk --release --split-per-abi`. Most modern phones use
`app-arm64-v8a-release.apk`.

### Installing straight to a phone over USB

1. On the phone, open **Settings → About phone** and tap **Build number**
   7 times to unlock **Developer options**.
2. In **Developer options**, turn on **USB debugging**.
3. Connect the phone and allow the debugging prompt.
4. Check that the phone is listed with `flutter devices`, then run
   `flutter install` to install the built APK, or `flutter run --release` to build
   and launch it.

> The release APK is signed with the debug key (see
> `android/app/build.gradle.kts`). That's fine for sharing with classmates, but
> APKs built on different computers have different signatures, so testers must
> uninstall the old version before installing one built elsewhere.

### Project structure

| File | Purpose |
| ---- | ------- |
| `lib/main.dart` | App start-up, login state, bottom navigation, payment status refresh |
| `lib/store_data.dart` | Products, categories, demo account, delivery fee, order model |
| `lib/login_page.dart` / `lib/signup_page.dart` | Log in and sign up screens |
| `lib/home_page.dart` | Product list, search, and category filter |
| `lib/cart_page.dart` | Cart screen |
| `lib/checkout_page.dart` | Checkout, payment, and Firebase order saving |
| `lib/shipping_page.dart` | Edit contact number and delivery address |
| `lib/orders_page.dart` | Order list and order tracking |
| `lib/profile_page.dart` | Profile screen |
| `lib/app_style.dart` | Colors and shared widgets |
| `android/app/src/main/AndroidManifest.xml` | Android app name (`android:label`) and internet permission |
| `supabase/functions/payment-status/` | Edge Function that returns an order's payment status |

### Backend services

- **Supabase Edge Functions**: online payments need two functions deployed on
  the linked Supabase project:
  - `create-invoice`: creates the Xendit test invoice and returns its checkout URL
  - `payment-status`: looks up an order's payment status by its `external_id`

  To deploy `payment-status` with the Supabase CLI:

  ```bash
  supabase functions deploy payment-status
  ```

- **Firebase Cloud Firestore**: orders are saved to the `orders` collection,
  but Firebase is only configured for the web build
  (`lib/firebase_options.dart`). The Android APK skips this step and keeps
  orders in the app only. To enable it on Android, run `flutterfire configure`
  and select Android.

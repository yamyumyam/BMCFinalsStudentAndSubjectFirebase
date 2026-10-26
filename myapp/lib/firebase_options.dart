import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Firebase is not configured for Android.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase is not configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase is not configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase is not configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is not configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHzoRltKP9PtePVljgIWfFj-kqBNrNQgs',
    appId: '1:962971963468:web:ce5f7d214868b8cc54a4e9',
    messagingSenderId: '962971963468',
    projectId: 'student-registration-be924',
    authDomain: 'student-registration-be924.firebaseapp.com',
    storageBucket: 'student-registration-be924.firebasestorage.app',
    measurementId: 'G-P11C70DVHT',
  );
}

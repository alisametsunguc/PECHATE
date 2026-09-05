// Generated for the PECHATE Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjD2w9XcfseWLOmduswhLbs8G2P7ouhCk',
    appId: '1:638321859619:web:d1191f8d7602a68c28a596',
    messagingSenderId: '638321859619',
    projectId: 'pechate-app-2026',
    authDomain: 'pechate-app-2026.firebaseapp.com',
    storageBucket: 'pechate-app-2026.firebasestorage.app',
    measurementId: 'G-PYMRZLWVTN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7Ne-Tq2Py18ZzYIg2vh7h_4n4kjKI1rk',
    appId: '1:638321859619:android:9e1da2d72f875f9e28a596',
    messagingSenderId: '638321859619',
    projectId: 'pechate-app-2026',
    storageBucket: 'pechate-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCKk3Qw5Ec7qIMiEwEWob9fqkkzl4RXQwQ',
    appId: '1:638321859619:ios:f68d07cf7678402a28a596',
    messagingSenderId: '638321859619',
    projectId: 'pechate-app-2026',
    storageBucket: 'pechate-app-2026.firebasestorage.app',
    iosBundleId: 'com.pechate.pechate',
  );
}

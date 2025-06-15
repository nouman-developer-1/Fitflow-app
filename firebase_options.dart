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
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web; // Fallback to web config for development
      case TargetPlatform.linux:
        return web; // Fallback to web config for development
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBFitflowDummyValueForWeb123456789',
    appId: '1:123456789012:web:a1b2c3d4e5f6g7h8i9j0k1l2',
    messagingSenderId: '123456789012',
    projectId: 'fitflow-app',
    authDomain: 'fitflow-app.firebaseapp.com',
    storageBucket: 'fitflow-app.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFitflowDummyValueForAndroid123456789',
    appId: '1:123456789012:android:a1b2c3d4e5f6g7h8i9j0k1l2',
    messagingSenderId: '123456789012',
    projectId: 'fitflow-app',
    storageBucket: 'fitflow-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFitflowDummyValueForIOS123456789',
    appId: '1:123456789012:ios:a1b2c3d4e5f6g7h8i9j0k1l2',
    messagingSenderId: '123456789012',
    projectId: 'fitflow-app',
    storageBucket: 'fitflow-app.appspot.com',
    iosClientId: '123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitflow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBFitflowDummyValueForMacOS123456789',
    appId: '1:123456789012:macos:a1b2c3d4e5f6g7h8i9j0k1l2',
    messagingSenderId: '123456789012',
    projectId: 'fitflow-app',
    storageBucket: 'fitflow-app.appspot.com',
    iosClientId: '123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitflow',
  );
}

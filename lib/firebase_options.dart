// Dummy firebase_options.dart
// Replace with actual Firebase configuration

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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHXg_Q41NBx7cwVqFRGzQaQ04VfSShLmc',
    appId: '1:872294285881:web:316e4f6c6a55100aee43e8',
    messagingSenderId: '872294285881',
    projectId: 'versus-47c7f',
    authDomain: 'versus-47c7f.firebaseapp.com',
    storageBucket: 'versus-47c7f.firebasestorage.app',
    measurementId: 'G-JY8RKKYFNL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCw4xgTi_UNEHxRN8UmHEiHta5BdQgQpYg',
    appId: '1:872294285881:android:2e111b4e42b32829ee43e8',
    messagingSenderId: '872294285881',
    projectId: 'versus-47c7f',
    storageBucket: 'versus-47c7f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBCr8cgVjHEfVQte3R1KHOuKkqPYS6DVHU',
    appId: '1:872294285881:ios:0a25c48d29afce42ee43e8',
    messagingSenderId: '872294285881',
    projectId: 'versus-47c7f',
    storageBucket: 'versus-47c7f.firebasestorage.app',
    iosBundleId: 'com.example.versus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBCr8cgVjHEfVQte3R1KHOuKkqPYS6DVHU',
    appId: '1:872294285881:ios:0a25c48d29afce42ee43e8',
    messagingSenderId: '872294285881',
    projectId: 'versus-47c7f',
    storageBucket: 'versus-47c7f.firebasestorage.app',
    iosBundleId: 'com.example.versus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBHXg_Q41NBx7cwVqFRGzQaQ04VfSShLmc',
    appId: '1:872294285881:web:8af623c2c885370bee43e8',
    messagingSenderId: '872294285881',
    projectId: 'versus-47c7f',
    authDomain: 'versus-47c7f.firebaseapp.com',
    storageBucket: 'versus-47c7f.firebasestorage.app',
    measurementId: 'G-2DGXDMN109',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'dummy',
    appId: 'dummy',
    messagingSenderId: 'dummy',
    projectId: 'dummy',
  );
}
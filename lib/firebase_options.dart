// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBNEpVAFWa8Sf7vANiiV1z7lt6a6gLsec',
    appId: '1:836318718507:web:82b0d14297b3f667d0186e',
    messagingSenderId: '836318718507',
    projectId: 'papb-project-de102',
    authDomain: 'papb-project-de102.firebaseapp.com',
    storageBucket: 'papb-project-de102.firebasestorage.app',
    measurementId: 'G-EVB5KTCD04',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDElGqz-jXPVGngh9WqkmfjLu3HN8X9xRs',
    appId: '1:836318718507:android:9ebfa6236790c787d0186e',
    messagingSenderId: '836318718507',
    projectId: 'papb-project-de102',
    storageBucket: 'papb-project-de102.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDg2mnoBZI0ku9SX_l-OKOJUtN1Z515-z0',
    appId: '1:836318718507:ios:b1d96cf8f50ad203d0186e',
    messagingSenderId: '836318718507',
    projectId: 'papb-project-de102',
    storageBucket: 'papb-project-de102.firebasestorage.app',
    iosBundleId: 'com.example.myProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDg2mnoBZI0ku9SX_l-OKOJUtN1Z515-z0',
    appId: '1:836318718507:ios:b1d96cf8f50ad203d0186e',
    messagingSenderId: '836318718507',
    projectId: 'papb-project-de102',
    storageBucket: 'papb-project-de102.firebasestorage.app',
    iosBundleId: 'com.example.myProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBBNEpVAFWa8Sf7vANiiV1z7lt6a6gLsec',
    appId: '1:836318718507:web:2bc692635bb3a616d0186e',
    messagingSenderId: '836318718507',
    projectId: 'papb-project-de102',
    authDomain: 'papb-project-de102.firebaseapp.com',
    storageBucket: 'papb-project-de102.firebasestorage.app',
    measurementId: 'G-SQNRNC279Q',
  );
}
// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAphQpdZQ_GIdvBcKJlfrQv9y7UO9w9w9Q',
    appId: '1:1043382085444:web:7d419090841a5e6cfdd911',
    messagingSenderId: '1043382085444',
    projectId: 'flutter-firebase-dersler-d5ce5',
    authDomain: 'flutter-firebase-dersler-d5ce5.firebaseapp.com',
    storageBucket: 'flutter-firebase-dersler-d5ce5.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvFM5xH5dxFQT4O_JkEgdrZC-xeOiexPg',
    appId: '1:1043382085444:android:7903e395d118a23dfdd911',
    messagingSenderId: '1043382085444',
    projectId: 'flutter-firebase-dersler-d5ce5',
    storageBucket: 'flutter-firebase-dersler-d5ce5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3zdF7adTvhjyQdlQFS2G5cwPSSrzc8ck',
    appId: '1:1043382085444:ios:2d713b3169ddc396fdd911',
    messagingSenderId: '1043382085444',
    projectId: 'flutter-firebase-dersler-d5ce5',
    storageBucket: 'flutter-firebase-dersler-d5ce5.appspot.com',
    androidClientId: '1043382085444-pdv6ev8m4s5gfb905schluk82scppqjn.apps.googleusercontent.com',
    iosClientId: '1043382085444-ur641du5gjk5u6vc9umankl1bpaoa884.apps.googleusercontent.com',
    iosBundleId: 'com.ismailkeyvan.flutterFirebaseAuth',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3zdF7adTvhjyQdlQFS2G5cwPSSrzc8ck',
    appId: '1:1043382085444:ios:2d713b3169ddc396fdd911',
    messagingSenderId: '1043382085444',
    projectId: 'flutter-firebase-dersler-d5ce5',
    storageBucket: 'flutter-firebase-dersler-d5ce5.appspot.com',
    androidClientId: '1043382085444-pdv6ev8m4s5gfb905schluk82scppqjn.apps.googleusercontent.com',
    iosClientId: '1043382085444-ur641du5gjk5u6vc9umankl1bpaoa884.apps.googleusercontent.com',
    iosBundleId: 'com.ismailkeyvan.flutterFirebaseAuth',
  );
}
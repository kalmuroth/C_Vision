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
    apiKey: 'AIzaSyDtjVzfF2BAoMlNKeXNhUNUzWx2b-hmvvA',
    appId: '1:999491928239:web:55a00db8b5d5a7663b145a',
    messagingSenderId: '999491928239',
    projectId: 'cvision-943d3',
    authDomain: 'cvision-943d3.firebaseapp.com',
    storageBucket: 'cvision-943d3.appspot.com',
    measurementId: 'G-5SXP105SK9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzilOqBpokVkKsqHXsy1R-dfQpX_U5Q0Q',
    appId: '1:999491928239:android:6532c4ed687087b63b145a',
    messagingSenderId: '999491928239',
    projectId: 'cvision-943d3',
    storageBucket: 'cvision-943d3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHxRJ-BBFk8lkavD0hRkzNt0OxA0gl4FE',
    appId: '1:999491928239:ios:d7c86584618e8bc33b145a',
    messagingSenderId: '999491928239',
    projectId: 'cvision-943d3',
    storageBucket: 'cvision-943d3.appspot.com',
    iosBundleId: 'com.cvision.cvision',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCHxRJ-BBFk8lkavD0hRkzNt0OxA0gl4FE',
    appId: '1:999491928239:ios:1d04d535de08ab7a3b145a',
    messagingSenderId: '999491928239',
    projectId: 'cvision-943d3',
    storageBucket: 'cvision-943d3.appspot.com',
    iosBundleId: 'com.cvision.cvision.RunnerTests',
  );
}

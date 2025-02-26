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
    apiKey: 'AIzaSyDO2uoHgp-3P6IVlqB9mbQgW2PWyNfz6XQ',
    appId: '1:63201236024:web:a3a7a5e9a949d0740ec2cd',
    messagingSenderId: '63201236024',
    projectId: 'freelancer-59466',
    authDomain: 'freelancer-59466.firebaseapp.com',
    storageBucket: 'freelancer-59466.appspot.com',
    measurementId: 'G-Z920GV5B8Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJgtG7UkMyS4ogSSeFJpSi_enMR54HugQ',
    appId: '1:63201236024:android:97a953d523cdaa190ec2cd',
    messagingSenderId: '63201236024',
    projectId: 'freelancer-59466',
    storageBucket: 'freelancer-59466.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZ1cMtIJexfhasb3Mv-GZ7RlMsonT2siQ',
    appId: '1:63201236024:ios:e8131b6e99802c130ec2cd',
    messagingSenderId: '63201236024',
    projectId: 'freelancer-59466',
    storageBucket: 'freelancer-59466.appspot.com',
    iosBundleId: 'com.example.freelancer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCZ1cMtIJexfhasb3Mv-GZ7RlMsonT2siQ',
    appId: '1:63201236024:ios:e8131b6e99802c130ec2cd',
    messagingSenderId: '63201236024',
    projectId: 'freelancer-59466',
    storageBucket: 'freelancer-59466.appspot.com',
    iosBundleId: 'com.example.freelancer',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDO2uoHgp-3P6IVlqB9mbQgW2PWyNfz6XQ',
    appId: '1:63201236024:web:3f9d258431d3de860ec2cd',
    messagingSenderId: '63201236024',
    projectId: 'freelancer-59466',
    authDomain: 'freelancer-59466.firebaseapp.com',
    storageBucket: 'freelancer-59466.appspot.com',
    measurementId: 'G-EMGSYY12NZ',
  );
}

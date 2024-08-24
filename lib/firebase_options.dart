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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1qeDk2BlFvT5jEbc3YLQy-efHuJKDhv4',
    appId: '1:581976899789:android:85dddb28440a0947cb6984',
    messagingSenderId: '581976899789',
    projectId: 'intrencity',
    storageBucket: 'intrencity.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIZ6Q4ocHYwbz8NssNJjTXzzxxZpCUs54',
    appId: '1:581976899789:ios:ada90b17000c3d01cb6984',
    messagingSenderId: '581976899789',
    projectId: 'intrencity',
    storageBucket: 'intrencity.appspot.com',
    androidClientId: '581976899789-n38kt8goqkgmaq8eg4j762tshb83h2qp.apps.googleusercontent.com',
    iosClientId: '581976899789-e0ikbguh8hbp1muuigeu2dpu8uc2dkdg.apps.googleusercontent.com',
    iosBundleId: 'com.example.intrencityProvider',
  );
}

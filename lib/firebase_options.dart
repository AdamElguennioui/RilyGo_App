// File generated for RileyQueue's Firebase Web integration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAEcXDfMeiTmQpsNHGST1Rlvr7BUboBLtM',
    authDomain: 'rilyqueue.firebaseapp.com',
    projectId: 'rilyqueue',
    storageBucket: 'rilyqueue.firebasestorage.app',
    messagingSenderId: '685704596686',
    appId: '1:685704596686:web:d46c9be211c825d51a549f',
    measurementId: 'G-FX1FGXDBP9',
  );
}

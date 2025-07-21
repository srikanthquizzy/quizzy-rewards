import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKy0kNxOMC0ZqOMIg0XJIaEpGDW-w2t68',
    appId: '1:771710622784:android:e10722f8f0ffc1e49493a5',
    messagingSenderId: '771710622784',
    projectId: 'quizzy-rewards',
    storageBucket: 'quizzy-rewards.firebasestorage.app',
    androidClientId: '', // Not available in your JSON — safe to leave empty
    databaseURL: '',
  );
}
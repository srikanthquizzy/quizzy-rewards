import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ Added import
import 'firebase_options.dart';

import 'screens/phone_auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart'; // ✅ Added quiz screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize(); // ✅ AdMob Initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzy Rewards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PhoneAuthScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/quiz': (_) => const QuizScreen(), // ✅ Quiz route added
      },
    );
  }
}
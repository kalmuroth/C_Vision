import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyDtjVzfF2BAoMlNKeXNhUNUzWx2b-hmvvA",
    authDomain: "cvision-943d3.firebaseapp.com",
    projectId: "cvision-943d3",
    storageBucket: "cvision-943d3.appspot.com",
    messagingSenderId: "999491928239",
    appId: "1:999491928239:web:55a00db8b5d5a7663b145a",
    measurementId: "G-5SXP105SK9"
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'welcome_screen',
      routes: {
        'welcome_screen': (context) => WelcomeScreen(),
        'registration_screen': (context) => RegistrationScreen(),
        'login_screen': (context) => LoginScreen(),
        'home_screen': (context) => HomeScreen()
      },
    );
  }
}

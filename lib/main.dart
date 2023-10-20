import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';
import 'welcome_screen.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';


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
  MyApp({super.key});
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Bottom Navigation Bar App"),
          backgroundColor: Colors.indigo,
        ),
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            LoginPage(),
            SignupPage(),
            HomePage(),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: RollingBottomBar(
          color: const Color.fromARGB(255, 255, 240, 219),
          controller: _pageController,
          flat: true,
          useActiveColorByDefault: false,
          items: const [
            RollingBottomBarItem(Icons.home,
                label: 'Login', activeColor: Colors.redAccent),
            RollingBottomBarItem(Icons.camera,
                label: 'Register', activeColor: Colors.blueAccent),
            RollingBottomBarItem(Icons.person,
                label: 'Home', activeColor: Colors.green),
          ],
          enableIconRotation: true,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
        ),
      ),
    );
  }
}

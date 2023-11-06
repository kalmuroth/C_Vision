import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';
import 'welcome_screen.dart';
import 'StartPage.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';
import 'HomePage.dart';


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
      routes: {
        'HomePage': (context) => HomePage()
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: null,
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            StartPage(),
            LoginPage(),
            SignupPage(),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: RollingBottomBar(
          color: const Color.fromARGB(255, 0x4C, 0x9F, 0xC1),
          controller: _pageController,
          flat: true,
          itemColor: Colors.white,
          useActiveColorByDefault: false,
          items: const [
            RollingBottomBarItem(Icons.home,
                label: 'Home', activeColor: Colors.white),
            RollingBottomBarItem(Icons.camera,
                label: 'Login', activeColor: Colors.white),
            RollingBottomBarItem(Icons.person,
                label: 'Register', activeColor: Colors.white),
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

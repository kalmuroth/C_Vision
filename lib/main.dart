import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';
import 'ScannerPage.dart';
import 'CameraPage.dart';


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

List<RollingBottomBarItem> nonAdminWidgets(_MyAppState parent) {
    return <RollingBottomBarItem>[
      RollingBottomBarItem(Icons.camera, label: 'Login', activeColor: Colors.white),
      RollingBottomBarItem(Icons.person, label: 'Register', activeColor: Colors.white),
    ];
  }

List<RollingBottomBarItem> adminWidgets(_MyAppState parent) {
  return <RollingBottomBarItem>[
    RollingBottomBarItem(Icons.camera, label: 'Login', activeColor: Colors.white),
    RollingBottomBarItem(Icons.person, label: 'Register', activeColor: Colors.white),
    RollingBottomBarItem(Icons.audiotrack, label: 'Scanner', activeColor: Colors.white),
    RollingBottomBarItem(Icons.beach_access, label: 'Camera', activeColor: Colors.white),
  ];
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController _pageController = PageController();

  void updateIsConnected(bool value) {
    setState(() {
      isConnected = value;
    });
  }

  static bool isConnected = false;
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: null,
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            LoginPage(pageController: _pageController, updateIsConnected: updateIsConnected),
            SignupPage(),
            ScannerPage(isConnected: isConnected),
            CameraPage(isConnected: isConnected)
          ],
        ),
        extendBody: true,
        bottomNavigationBar: RollingBottomBar(
          color: const Color.fromRGBO(59,105,120,1.0),
          controller: _pageController,
          flat: true,
          itemColor: Colors.white,
          useActiveColorByDefault: false,
          items: isConnected ? adminWidgets(this) : nonAdminWidgets(this),
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
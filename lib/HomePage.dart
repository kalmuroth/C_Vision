import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rounded_button.dart';
import 'rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart'; 

User? loggedinUser;

class HomePage extends StatefulWidget {
  bool isConnected; // Define the parameter

  HomePage({required this.isConnected}); // Named constructor to accept the parameter

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  String result = '';
  String productName = '';
  bool showSpinner = false;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getProduct() async {
    if (result.isNotEmpty) {
      try {
        final document = await FirebaseFirestore.instance
            .collection('product')
            .where('value', isEqualTo: result)
            .get();

        if (document.docs.isNotEmpty) {
          setState(() {
            productName = document.docs.first['name'];
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set the Scaffold's background color to transparent
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF9F9FB), // Set the color to #F9F9FB
        ),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleBarcodeScannerPage(),
                      ),
                    );

                    if (res is String) {
                      setState(() {
                        result = res;
                      });
                      getProduct(); // Call the getProduct method after receiving the result
                    }
                  },
                  child: const Text('Open Scanner'),
                ),
                Text('Barcode Result: $result'),
                Text('Product Value: $productName'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

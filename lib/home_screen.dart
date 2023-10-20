import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? loggedinUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  String result = '';
  String productName = '';

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rounded_button.dart';
import 'rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart'; 

User? loggedinUser;

class ScannerPage extends StatefulWidget {
  bool isConnected; // Define the parameter

  ScannerPage({required this.isConnected}); // Named constructor to accept the parameter

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _auth = FirebaseAuth.instance;
  String result = '';
  String productName = '';
  String productId = '';
  List<Map<String, dynamic>>? products;
  bool showSpinner = false;

  void initState() {
    super.initState();
    getCurrentUser();
    loadProducts();
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

  Future<void> getProduct() async {
    if (result.isNotEmpty) {
      try {
        final document = await FirebaseFirestore.instance
            .collection('product')
            .where('value', isEqualTo: result)
            .get();

        if (document.docs.isNotEmpty) {
          final documentSnapshot = document.docs.first;
          setState(() {
            productId = documentSnapshot.id;
            productName = document.docs.first['name'];
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void postProduct() async {
  try {
    final User? user = _auth.currentUser;
    if (user != null) {
      if (productId.isNotEmpty) {
        final documentReference = FirebaseFirestore.instance.collection('product').doc(productId);
        await documentReference.update({
          'user': user.uid
        });
        setState(() {
          productId = '';
        });
      }
    }
  } catch (e) {
    print(e);
  }
}

Future<List<Map<String, dynamic>>?> getProductsByCurrentUser() async {
  final User? user = _auth.currentUser;
  print("cc");
  if (user != null) {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('user', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  } else {
    return null;
  }
}

Future<void> loadProducts() async {
  products = await getProductsByCurrentUser();
  setState(() {}); // Refresh the UI to display the products
}

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFFF9F9FB),
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
                    await getProduct();
                    postProduct();
                  }
                },
                child: const Text('Open Scanner'),
              ),
              Text('Barcode Result: $result'),
              Text('Product Value: $productName'),
              const SizedBox(height: 20),
              Text(
                'My Products:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: products != null
                  ? ListView.builder(
                      itemCount: products!.length,
                      itemBuilder: (context, index) {
                        final product = products![index];
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text(product['value']),
                        );
                      },
                    )
                  : Center(
                      child: Text('No products found or user not authenticated.'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

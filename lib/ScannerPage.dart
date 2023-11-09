import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart'; 

User? loggedinUser;

final makeCard = (Map<String, dynamic> product) => Card(
  elevation: 8.0,
  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
  color: Colors.transparent, // Set the card background color to transparent
  child: Container(
    decoration: BoxDecoration(
      color: Color.fromRGBO(59,105,120,1.0),
      borderRadius: BorderRadius.circular(20),
    ),
    child: makeListTile(product),
  ),
);

final makeListTile = (Map<String, dynamic> product) => ListTile(
  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
  leading: Container(
    padding: EdgeInsets.only(right: 12.0),
    decoration: new BoxDecoration(
      border: new Border(
        right: new BorderSide(width: 1.0, color: Colors.white))),
    child: Icon(Icons.autorenew, color: Colors.white),
  ),
  title: Text(
    product['name'],
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  subtitle: Row(
    children: <Widget>[
      Icon(Icons.linear_scale, color: Colors.red),
      Text(" Intermediate", style: TextStyle(color: Colors.white))
    ],
  ),
  trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
);

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
    return SafeArea(
      child: Scaffold(
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
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: products != null
                            ? ListView.builder(
                              itemCount: products!.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                final product = products![index];
                                return makeCard(product);
                              },
                            )
                          : Center(
                            child: CircularProgressIndicator(), // Show spinner while loading
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FloatingActionButton(
                        onPressed: () async {
                          setState(() {
                            showSpinner = true; // Set spinner to true while loading
                          });
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
                            await loadProducts(); // Refresh the list after adding a product
                          }
                          setState(() {
                            showSpinner = false; // Set spinner to false after loading
                          });
                        },
                        child: Icon(Icons.add),
                        backgroundColor: Color.fromRGBO(59,105,120,1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

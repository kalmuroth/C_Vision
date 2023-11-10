import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rounded_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

User? loggedinUser;

final makeCard = (Map<String, dynamic> product, VoidCallback onDismiss) => Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      color: Colors.transparent, // Set the card background color to transparent
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(59, 105, 120, 1.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDismiss(),
            background: Container(
              alignment: AlignmentDirectional.centerEnd,
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: makeListTile(product),
          ),
        ),
      ),
    );

final makeListTile = (Map<String, dynamic> product) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.network(
          product['imageUrl'] ?? '',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        (product['productName'] ?? '') + " , " + (product['brands'] ?? ''),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(Icons.linear_scale, color: Colors.red),
          Text(
            " ${product['quantity'] ?? ''}",
            style: TextStyle(color: Colors.white),
          )
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
        final response = await http.get(
          Uri.parse('https://world.openfoodfacts.org/api/v2/product/$result.json'),
        );

        if (response.statusCode == 200) {
          print("test");
          Map<String, dynamic> data = json.decode(response.body);

          String productName = data['product']['product_name'] != null &&
              data['product']['product_name'] != ""
              ? data['product']['product_name']
              : 'No Name';

          String brands = data['product']['brands'] != null &&
              data['product']['brands'] != ""
              ? data['product']['brands']
              : 'No Brand';

          String quantity = data['product']['quantity'] != null &&
              data['product']['quantity'] != ""
              ? data['product']['quantity']
              : 'No Quantity';

          String imageUrl = data['product']['image_front_small_url'] != null && data['product']['image_front_small_url'] != ""
            ? data['product']['image_front_small_url']
            : '';

          final documentReference =
              FirebaseFirestore.instance.collection('product').doc();

          await documentReference.set({
            'barCode': result,
            'productName': productName,
            'brands': brands,
            'quantity': quantity,
            'imageUrl': imageUrl
          });

          setState(() {
            productId = documentReference.id;
          });
        } else {
          print('Failed to fetch product details: ${response.statusCode}');
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
          final documentReference =
              FirebaseFirestore.instance.collection('product').doc(productId);
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
          return querySnapshot.docs
              .map((doc) => {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  })
              .toList();
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
    setState(() {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && (products == null || products!.isEmpty)) {
          setState(() {
            showSpinner = false;
          });
        }
      });
    });
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final product = products![index];
                                    return makeCard(product, () {
                                      // Remove the item from the database
                                      FirebaseFirestore.instance
                                          .collection('product')
                                          .doc(product['id'])
                                          .delete();

                                      // Refresh the UI to remove the dismissed item
                                      setState(() {
                                        products!.removeAt(index);
                                      });
                                    });
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
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
                            showSpinner = true;
                          });
                          var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SimpleBarcodeScannerPage(),
                            ),
                          );
                          if (res is String) {
                            setState(() {
                              result = res;
                            });
                            await getProduct();
                            postProduct();
                            await loadProducts();
                          }
                          setState(() {
                            showSpinner = false;
                          });
                        },
                        child: Icon(Icons.add),
                        backgroundColor: Color.fromRGBO(59, 105, 120, 1.0),
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

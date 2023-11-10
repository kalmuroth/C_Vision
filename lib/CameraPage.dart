import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String cameraUrl = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    getCurrentUserCameraUrl();
  }

  void getCurrentUserCameraUrl() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        var cameraQuerySnapshot = await _firestore
            .collection('camera')
            .where('iduser', isEqualTo: user.uid)
            .get();

        if (cameraQuerySnapshot.docs.isNotEmpty) {
          var cameraData = cameraQuerySnapshot.docs.first;
          setState(() {
            cameraUrl = cameraData['url'];
            userId = user.uid; // Ajout de l'ID utilisateur
          });
          print(
              "User ID: $userId"); // Affichage de l'ID utilisateur dans la console
          print("Camera URL: $cameraUrl");
        } else {
          print("No camera found for this user");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: Center(
        child: cameraUrl.isEmpty
            ? Text('No camera found')
            : InkWell(
                child: Text('User ID: $userId\nCamera URL: $cameraUrl'),
                onTap: () => _launchURL(cameraUrl),
              ),
      ),
    );
  }
}

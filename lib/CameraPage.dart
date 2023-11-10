import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  UniqueKey _key = UniqueKey();

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

  Future<String> fetchUrlWithHeaders(String url) async {
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'ngrok-skip-browser-warning': 'any-value',
        'User-Agent': 'your-custom-user-agent',
      },
    );
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: cameraUrl.isEmpty
        ? Text('No camera found')
        : WebViewPlus(
          key: _key,
          initialUrl: cameraUrl,
          gestureRecognizers: gestureRecognizers,
          onWebViewCreated: (controller) {
            controller.loadUrl(
              cameraUrl,
              headers: {
                'ngrok-skip-browser-warning': 'any-value',
                'User-Agent': 'your-custom-user-agent',
              },
            );
          },
        ),
    );
  }
}

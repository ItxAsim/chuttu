
import 'package:chuttu/perfessional%20authentications/perSignunp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'customer Authentication/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: 'AIzaSyB7kCc4kTXML82U5yktjrYxUVFZM9Dp-U0',appId: '1:1018771886293:android:eb72489b53a9fef1e5d25c',messagingSenderId: '1018771886293',projectId: 'chuttu-29802',
    storageBucket: "gs://chuttu-29802.appspot.com",
  ));

  runApp( MaterialApp(
      home:PerSignupPage(),
  ));
}

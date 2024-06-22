
import 'package:chuttu/Admin/AdminLoginPage.dart';
import 'package:chuttu/Splash%20screen.dart';
import 'package:chuttu/payment.dart';
import 'package:chuttu/perfessional%20authentications/perSignunp.dart';
import 'package:chuttu/selctionpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
}


Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: 'AIzaSyB7kCc4kTXML82U5yktjrYxUVFZM9Dp-U0',appId: '1:1018771886293:android:eb72489b53a9fef1e5d25c',messagingSenderId: '1018771886293',projectId: 'chuttu-29802',
    storageBucket: "gs://chuttu-29802.appspot.com",
  ));

 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
 if(kIsWeb)
  runApp( MaterialApp(
    home:AdminLoginPage(),
  ));
else{
   Stripe.publishableKey  ='pk_test_51PKey5RqpLRvpy66lVzEVRMZnSlIwFBQFYbZqVRtrhiMyisPC2EvLjTlj0wMGfgIuLWSvuzt19jLBVKbPHQW85np003xB4VDJj';
  runApp( MaterialApp(
      home:SplashScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
  ));}
}

import 'dart:async';

import 'package:chuttu/selctionpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(Duration(seconds: 2), () {
      // Replace this with your desired navigation logic
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Selectionpage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/designbg.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/Logo.png',
                width: 400,
                height: 500,
              ).animate().fadeIn(duration: 1000.ms).slideY(begin: 1, end: 0, duration: 1000.ms),
              SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}

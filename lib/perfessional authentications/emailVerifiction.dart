import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Perfessional Service Page.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = FirebaseAuth.instance;
  User? _user;
  bool _isEmailVerified = false;
  bool _isSendingVerification = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _isEmailVerified = _user?.emailVerified ?? false;

    if (!_isEmailVerified) {
      _sendVerificationEmail();
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      setState(() {
        _isSendingVerification = true;
      });
      await _user?.sendEmailVerification();
      setState(() {
        _isSendingVerification = false;
      });
      _showSnackbar('Verification email has been sent');
    } catch (e) {
      setState(() {
        _isSendingVerification = false;
      });
      _showSnackbar('Failed to send verification email: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
    );
  }

  Future<void> _checkEmailVerified() async {
    await _user?.reload();
    setState(() {
      _isEmailVerified = _user?.emailVerified ?? false;
    });
    if (_isEmailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfessionalServicesPage()), // Make sure to import this page
      );
    } else {
      _showSnackbar('Email is not verified yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'A verification email has been sent to ${_user?.email}. Please check your email and verify your account.',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isSendingVerification ? null : _sendVerificationEmail,
              child: _isSendingVerification
                  ? CircularProgressIndicator()
                  : Text('Resend Verification Email'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _checkEmailVerified,
              child: Text('I have verified my email'),
            ),
          ],
        ),
      ),
    );
  }
}

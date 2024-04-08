import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chuttu/customer/home.dart';



class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _smsCodeController = TextEditingController();
  String _verificationId = '';

  Future<void> _verifyPhoneNumber() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text, // Replace with your country code if needed.
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _showSnackbar('phone verification successfull.');
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackbar('Verification failed: ${e.code}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          _showSnackbar('Verification code sent to your phone.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCodeController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _showSnackbar('Phone number verfication   successful.');
      Navigator.push(context, MaterialPageRoute(builder: (context)=>myhome()));

    } catch (e) {
      _showSnackbar('Error: $e');
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Login'),
      ),
      body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: screenWidth, // Match the screen width
                height: screenHeight, // Match the screen height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/new.png"),
                    fit: BoxFit.fill, // Stretch to fill the entire screen
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: 'Phone Number'
                          ,helperText: "+921234567",
                          border:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),)
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _verifyPhoneNumber,
                      child: Text('Send Verification Code'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _smsCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Verification Code',
                          border:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),)
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _signInWithPhoneNumber,
                      child: Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}

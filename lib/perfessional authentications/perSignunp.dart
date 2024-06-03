
import 'package:chuttu/perfessional%20authentications/Perfessional%20Service%20Page.dart';
import 'package:chuttu/perfessional%20authentications/perLogin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'emailVerifiction.dart';

class PerSignupPage  extends StatefulWidget {
  @override
  _PerSignupPageState createState() => _PerSignupPageState();
}

class _PerSignupPageState extends State<PerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool signed=false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool  verify=false;
  TextEditingController _name = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  String _Profile_url='';
  TextEditingController _smsCodeController = TextEditingController();
  String _verificationId = '';
  bool  _obscureText=true;
  Future<void> _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCodeController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _showSnackbar('Phone number verfication   successful.');
     setState(() {
       verify=true;
     });

    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _verifyPhoneNumber() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+92${_phoneNumber.text}', // Replace with your country code if needed.
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
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black.withOpacity(0.7),

      ),
    );
  }
  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      try {
        var authResult = await _auth.createUserWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );

        if (authResult.user != null) {
          // Send email verification
          await authResult.user?.sendEmailVerification();

          // Save additional user details to Firestore
          await _firestore.collection('perfessionals').doc(authResult.user?.uid).set({
            'name': _name.text,
            'address': _address.text,
            'phoneNumber': _phoneNumber.text,
            'email': _email.text,
            'Profile_url': _Profile_url,
          });

          _showSnackbar('Account created successfully. Please check your email to verify your account.');

          // Redirect to the EmailVerificationPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmailVerificationPage()),
          );
        }
      } catch (e) {
        setState(() {
          signed = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error during sign up: $e")));
        print('Exception @createAccount: $e');
        // Handle any errors (e.g., invalid email, weak password, etc.)
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(

      body: Stack(

          children:[
            Container(
              width: screenWidth, // Match the screen width
              height: screenHeight, // Match the screen height
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/designbg.png"),
                  fit: BoxFit.fill, // Stretch to fill the entire screen
                ),
              ),
            ),
            Image.asset('images/Logo.png'),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 255),
                    Text("Create an  Professional account",style: GoogleFonts.croissantOne(
                      fontStyle:FontStyle.italic,
                      fontSize: 20,
                    ),),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                    color: Colors.black87
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  icon: Icon(Icons.email),
                                  border:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),)
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscureText,
                              style: TextStyle(
                                  color: Colors.black54
                              ),
                              decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                  border:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),)

                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  signed=false;
                                  return 'Please enter your Password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                                controller: _name,
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                    color: Colors.black87
                                ),
                                decoration: InputDecoration(
                                  labelText: 'NAME',
                                  icon: Icon(Icons.person),
                                  border:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),)
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                                controller: _address,
                                keyboardType: TextInputType.streetAddress,
                                style: TextStyle(
                                    color: Colors.black87
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Adress',
                                  icon: Icon(Icons.home),
                                  border:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),)
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                                controller: _phoneNumber,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    color: Colors.black87
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: "write without 0 like 3000..",
                                  icon: Icon(Icons.phone),
                                  border:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),)
                            ),
                            SizedBox(height: 16.0),
                            /*ElevatedButton(

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
                            ),*/


                            ElevatedButton(

                              onPressed: (){
                                _createAccount();
                                setState(() {
                                  signed=true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  // do something
                                }


                              },
                              child: signed?CircularProgressIndicator():Text('Sign up'),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(const EdgeInsetsDirectional.all(3.0))
                              ),
                            ),


                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PerLoginPage()));
                              },
                              child: Text(
                                "Already have an account ",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.indigoAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),

                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool signed=false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController _name = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  String _Profile_url='';

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      try {
        var authResult = await _auth.createUserWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );

        if (authResult.user != null) {
          // Save additional user details to Firestore
          await _firestore.collection('users').doc(authResult.user?.uid).set({
            'name': _name.text,
            'address': _address.text,
            'phoneNumber': _phoneNumber.text,
            'email': _email.text,
            'Profile_url':_Profile_url,
          });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      } catch (e) {
        setState(() {
          signed=false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error during sign in: $e")));
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
                    Text("Create an account  ",style: GoogleFonts.croissantOne(
                      fontStyle:FontStyle.italic,
                      fontSize: 30,
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
                              obscureText: true,
                              style: TextStyle(
                                  color: Colors.black54
                              ),
                              decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  labelText: 'Password',
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
                                  icon: Icon(Icons.phone),
                                  border:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),)
                            ),
                            SizedBox(height: 16.0),


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
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
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

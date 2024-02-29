import 'dart:ui';

import 'package:chuttu/Admin/AdminAprroval.dart';
import 'package:chuttu/Admin/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  Future<void> _login() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Check if the user is an admin
        // You can implement your own logic to determine admin status
        // For example, by checking a field in Firestore or a custom claim
        if (user.email == 'admin0535@gmail.com') {
          // Navigate to the admin dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => navbar()),
          );
        } else {
          setState(() {
            _errorMessage = 'You are not authorized to access this page.';
          });
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
      ),
      body: Stack(
        children:[

        Container(
          // Match the screen height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/webLogin.jpg"),
              alignment: Alignment.bottomRight,

            ),
          ),
        ), Center(
          child: Container(
            width: 350, // Set the desired width for the card
            height: 450, // Set the desired height for the card
            child: Card(
              elevation: 4,
              child: Stack(

                children:[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(

                        image: AssetImage(
                          'images/blur.jpg',
                        ),
                        fit: BoxFit.cover,

                      ),

                    ),

                  ),
                  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(labelText: 'Email' ,icon: Icon(Icons.email)),
                    ),
                    TextField(
                      controller: _passwordController,
                      style:TextStyle(color: Colors.white,),
                      decoration: InputDecoration(labelText: 'Password',icon: Icon(Icons.lock)),
                      obscureText: true,
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
            ]  ),
            ),
          ),
        ),
     ] ),
    );
  }
}
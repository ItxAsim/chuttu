import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class forgetpassword extends StatefulWidget {
  const forgetpassword({super.key});

  @override
  State<forgetpassword> createState() => _forgetpasswordState();
}

class _forgetpasswordState extends State<forgetpassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String _email = "";
  bool _isLoading = false;
  String _errorMessage = "";
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return  Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth, // Match the screen width
            height: screenHeight, // Match the screen height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/new.png"),
                fit: BoxFit.fill, // Stretch to fill the entire screen
              ),
            ),
          ),
          Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter your registered email address to receive a password reset link:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) => value!.isEmpty ? 'Email is required' : null,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                    ),
                    onChanged: (value) => _email = value,
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      _formKey.currentState!.validate();
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = "";
                        });

                        try {
                          await _auth.sendPasswordResetEmail(email: _email);
                          Navigator.pop(context);
                          _emailController.clear();
                          _showSuccessDialog();
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                            _errorMessage = e.toString();
                          });
                        }
                      }
                    },
                    child: Text(_isLoading ? 'Sending...' : 'Send Password Reset Link'),
                  ),
                  if (_errorMessage.isNotEmpty)
                    SizedBox(height: 10.0),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success!'),
        content: Text('A password reset link has been sent to your email address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

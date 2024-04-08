import 'package:chuttu/customer%20Authentication/signuppage.dart';
import 'package:chuttu/perfessional%20authentications/Perfessional%20Service%20Page.dart';
import 'package:chuttu/perfessional%20authentications/perSignunp.dart';
import 'package:chuttu/perfessional%20authentications/perhome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../customer Authentication/ForgetPassword.dart';
import '../customer/home.dart';
class PerLoginPage extends StatefulWidget {
  @override
  _PerLoginPageState createState() => _PerLoginPageState();
}

class _PerLoginPageState extends State<PerLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  bool signed = false;

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('User signed in: ${userCredential.user?.email}');
      //signed = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );
      User? user = userCredential.user;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => perhome()));
    } catch (e) {
      setState(() {
        signed=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during sign in: $e")),
      );
      print('Error during sign in: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController.clear();
    _passwordController.clear();
    signed=false;
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
                  image: AssetImage("images/new.png"),
                  fit: BoxFit.fill, // Stretch to fill the entire screen
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 150),
                    Text("LOGIN as perfessional  ",style: GoogleFonts.croissantOne(
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
                                controller: _emailController,
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
                              controller: _passwordController,
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


                            ElevatedButton(

                              onPressed: (){
                                _signIn();
                                setState(() {
                                  signed=true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  // do something
                                }


                              },
                              child: signed? CircularProgressIndicator() :Text('Sign In'),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(const EdgeInsetsDirectional.all(3.0))
                              ),
                            ),

                            /*SizedBox(height: 16.0),*/
                           /* ElevatedButton(
                              onPressed: (){

                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneLogin()));

                              },
                              child: Text('Sign In with Phone number'),
                            ),*/

                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>forgetpassword()));
                              },
                              child: Text(
                                "forget password? ",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.indigoAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),

                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PerSignupPage()));
                              },
                              child: Text(
                                "can't have any account ",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.indigoAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),

                            ),


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

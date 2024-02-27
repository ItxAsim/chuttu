import 'package:chuttu/customer%20Authentication/login.dart';
import 'package:chuttu/perfessional%20authentications/perLogin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class Selectionpage extends StatelessWidget {
  const Selectionpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children:[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/new.png"),
                fit: BoxFit.fill, // Stretch to fill the entire screen
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Choose an any option ",style: GoogleFonts.croissantOne(
                  fontStyle:FontStyle.italic,
                  fontSize: 20,
                ),),
                ElevatedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage())),
                    child: Text(" As a  customer    ")),
                ElevatedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>PerLoginPage())),
                    child: Text("As a Proffessional"))
              ],
            ),
          )
        ]
      )
    );
  }
}

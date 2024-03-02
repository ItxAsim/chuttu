import 'package:chuttu/perfessional%20authentications/bottomNavigationPerfessional.dart';
import 'package:chuttu/perfessional%20authentications/usergig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class perhome extends StatefulWidget {
  const perhome({super.key});

  @override
  State<perhome> createState() => _perhomeState();
}

class _perhomeState extends State<perhome> {
  @override
  int _selectedIndex=0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pop(context); // Close the drawer
      // Navigate to the sign-in page or any other page as needed
    } catch (e) {

      print('Error signing out: $e');
      // Handle sign-out errors
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HOME"),

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
      ListTile(
        title: Text('My Gigs'),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>UserGigPage()));

        }),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
                _signOut(context);
                Navigator.pop(context);

              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [

        ],
      ),
      bottomNavigationBar: Perbottomnavigation(
    items: [
    BottomNavigationBarItem(
    icon: Icon(Icons.home ),
    label: 'home',),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: 'create gig',
      ),
    BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'DASHBOARD',
    ),

    ],
    selectedIndex: _selectedIndex,
    ),
    );
  }
}

import 'package:chuttu/servicepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Servicedetailspage.dart';
import 'bottomnavigation.dart';
class myhome extends StatefulWidget {
  const myhome({super.key});

  @override
  State<myhome> createState() => _myhomeState();
}

class _myhomeState extends State<myhome> {
  int _selectedIndex = 0;
  final List<String> services = [
    'Home Mantaince',
    'Tailoring Srvicing',
    'Beauty & personal care',
    'Car Maintainance Services',

  ];
  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(title: Text("Chotu"),),
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
              title: Text('Show Services'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ServicePage()),
                );
              },
            ),
            ListTile(
              title: Text('Add services'),
              onTap: () {
                _signOut(context);
                Navigator.pop(context);

              },
              trailing: Icon(Icons.add),
            ),
            ListTile(
              title: Text('Biddig'),
              onTap: () {
                _signOut(context);
                Navigator.pop(context);

              },
              trailing: Icon(Icons.handyman),
            ),
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
      body:  Stack(
          children: [
        /* StreamBuilder(
         stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot post = snapshot.data!.docs[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    title: Text(post['description']),
                    subtitle: Text(post['email']),
                  ),
                  Image.network(post['imageUrl']),
                ],
              ),
            );
          },
        );*/

          SingleChildScrollView(
            child: Column(
              children: [
                Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                children: [
                CircleAvatar(
                radius: 80.0,
                backgroundImage: AssetImage('images/chair.jpg'), // Replace with your image path
                ),
                SizedBox(height: 20.0),
                Text(
                'Chairs have been around for thousands of years, with simple forms dating back to ancient Egypt and Mesopotamia Different cultures developed their own unique chair designs, reflecting their materials, lifestyles, and social structures. The iconic bentwood chair was invented in the 19th century, marking a major shift in chair design with its innovative steam-bending technique.',
                style: TextStyle(fontSize: 16.0),
                ),

                ],
                ),
                ),
                      ),
                SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 80.0,
                          backgroundImage: AssetImage('images/tap.jpg'), // Replace with your image path
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Chairs have been around for thousands of years, with simple forms dating back to ancient Egypt and Mesopotamia Different cultures developed their own unique chair designs, reflecting their materials, lifestyles, and social structures. The iconic bentwood chair was invented in the 19th century, marking a major shift in chair design with its innovative steam-bending technique.',
                          style: TextStyle(fontSize: 16.0),
                        ),


                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
          bottomnavigation(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person ),
                  label: 'HOME',),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'ADD POST',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'PROFILE',
                ),
              ],
              selectedIndex: _selectedIndex,
            ),
          ],

      ),
    );
  }
}

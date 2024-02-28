import 'package:chuttu/bottomnavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottomNavigationPerfessional.dart';

class UserGigsPage extends StatefulWidget {
  @override
  _UserGigsPageState createState() => _UserGigsPageState();
}

class _UserGigsPageState extends State<UserGigsPage> {
  late final User _user;
  late final Stream<QuerySnapshot> _gigsStream;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _gigsStream = FirebaseFirestore.instance
        .collection('perfessionals')
        .doc(_user.uid)
        .collection('gigs')
        .snapshots();
  }
   int _selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Gigs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _gigsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No gigs available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final gig = snapshot.data!.docs[index];
              final title = gig['title'] ?? '';
              final description = gig['description'] ?? '';
              final location = gig['location'] ?? '';
              final price = gig['price'] ?? '';
              final status = gig['status'] ?? '';
              final List<dynamic> images = gig['images'] ?? [];

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: $description'),
                      Text('Location: $location'),
                      Text('Price: $price'),
                      Text('Status: $status'),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: images.map<Widget>((image) {
                          return Image.network(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

        },

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

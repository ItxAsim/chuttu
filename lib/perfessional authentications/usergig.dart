import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserGigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Gigs'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('perfessionals').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final gigData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> gigs = gigData['gigs'] ?? [];

          return ListView.builder(
            itemCount: gigs.length,
            itemBuilder: (context, index) {
              final gig = gigs[index] as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title: ${gig['title'] ?? ''}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text('Description: ${gig['description'] ?? ''}'),
                      SizedBox(height: 8.0),
                      Text('Status: ${gig['gigstatus'] ?? ''}'),
                      SizedBox(height: 8.0),
                      if (gig['gigimages'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            gig['gigimages'][0],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

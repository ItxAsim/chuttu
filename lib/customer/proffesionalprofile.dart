import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfessionalProfile extends StatelessWidget {
  final String professionalId;

  ProfessionalProfile({required this.professionalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final professionalData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract professional information
          final String name = professionalData['name'] ?? '';
          final String phoneNumber = professionalData['phoneNumber'] ?? '';
          final String profileImageUrl = professionalData['profileImageUrl'] ?? '';
          final double rating = professionalData['rating'] ?? 0.0;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Name: $name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.call),
                    title: Text(
                      'Phone Number: $phoneNumber',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 2,
                  child: Text(
                    'Rating: ${rating.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}


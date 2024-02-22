import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalDashboard extends StatefulWidget {
  @override
  _ProfessionalDashboardState createState() => _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  late String userId;
  late Stream<DocumentSnapshot> _professionalStream;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _professionalStream = FirebaseFirestore.instance
          .collection('perfessionals')
          .doc(userId)
          .snapshots();
    }
  }

  Future<void> _updateProfileInfo(Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('perfessionals')
          .doc(userId)
          .update(newData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<void> _uploadImageAndUpdateProfile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await storageRef.putFile(imageFile);
      final String downloadURL = await storageRef.getDownloadURL();

      await _updateProfileInfo({'Profile_url': downloadURL});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Dashboard'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _professionalStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No data available'),
            );
          }

          final professionalData = snapshot.data!;
          final services = professionalData.get('services') as List<dynamic>?;
          final name = professionalData.get('name') as String?;
          final email = professionalData.get('email') as String?;
          final phoneNumber = professionalData.get('phoneNumber') as String?;
          final profileURL = professionalData.get('Profile_url') as String?;
          final status = professionalData.get('status') as String?;


          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profileURL != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileURL),
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _uploadImageAndUpdateProfile,
                  child: Text('Upload Profile Picture'),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Profile Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                ListTile(
                  title: Text('Name: $name'),
                ),
                ListTile(
                  title: Text('Email: $email'),
                ),
                ListTile(
                  title: Text('Phone Number: $phoneNumber'),
                ),
                SizedBox(height: 16.0),

                Text(
                  'Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                if (services != null)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final serviceName = services[index];
                      return ListTile(
                        title: Text(serviceName),
                        trailing:Text("$status") ,
                      );
                    },
                  ),
                SizedBox(height: 16.0),
                Text(
                  'Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Implement order list display for pending and completed orders
              ],
            ),
          );
        },
      ),
    );
  }
}

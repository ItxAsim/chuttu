import 'dart:io';

import 'package:chuttu/perfessional%20authentications/Document%20verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfessionalDashboard extends StatefulWidget {
  @override
  _ProfessionalDashboardState createState() => _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  late String userId;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _imageUrl;

  late Stream<DocumentSnapshot> _professionalStream;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _professionalStream = FirebaseFirestore.instance
          .collection('perfessionals')
          .doc(userId)
          .snapshots();
    }
    _getCurrentUserImageUrl();
  }

  Future<void> _getCurrentUserImageUrl() async {
    try {
      final User user = _auth.currentUser!;
      if (user.photoURL != null) {
        setState(() {
          _imageUrl = user.photoURL!;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _uploadImage(pickedFile);
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error picking image: $error'),
        ),
      );
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        // Storage permission is granted, proceed with image upload
        final Reference ref = _storage.ref().child(
            'user_profile_pictures/${_auth.currentUser!.uid}/${image.path}');
        await ref.putFile(File(image.path));
        final String downloadUrl = await ref.getDownloadURL();
        setState(() {
          _imageUrl = downloadUrl;
        });
        _updateUserProfile(downloadUrl);
      } else {
        // Storage permission is not granted, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Storage permission required!'),
          ),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error uploading image: $error'),
        ),
      );
    }
  }


  Future<void> _updateUserProfile(String url) async {
    try {
      final User user = _auth.currentUser!;
      await user.updateProfile(photoURL: url);
      await FirebaseFirestore.instance
          .collection('perfessionals')
          .doc(user.uid)
          .update({'profileImageUrl': url});
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error updating profile picture: $error'),
        ),
      );
    }
  }
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _uploadImage(pickedFile);
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error picking image: $error'),
        ),
      );
    }
  }
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _showImageFullScreen(BuildContext context, String imageUrl) {
    // Use the Hero widget for smooth transition animation
    Navigator.push(
      context, // Pass context directly
      MaterialPageRoute(
        builder: (context) => Hero(
          tag: imageUrl, // Use the image URL as the tag
          child: Scaffold(
            appBar: AppBar(
              title: Text('Image'),
            ),
            body: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Adjust as needed
              ),
            ),
          ),
        ),
      ),
    );
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
          var profileUrl = professionalData.get('profileImageUrl') as String?;
          final status =professionalData.get('status') as String?;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profileUrl != null)
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, profileUrl),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(profileUrl),
                        radius: 75.0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FloatingActionButton(
                            onPressed: _showImageSourceDialog,
                            tooltip: 'Update Profile Picture',
                            child: Icon(Icons.add,color: Colors.white,size: 30,),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 16.0),
                Text(
                  'Profile Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Name: $name'),
                  
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email: $email'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Phone Number: $phoneNumber'),
                  ),
                ),
                InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>Documentverification())),
                  child: Card(
                    
                    child: ListTile(
                      
                      title: Text('Dcoument verfication'),
                      trailing: status=='approved'?Icon(Icons.verified ,color: Colors.blueAccent,):Text("pending"),
                    ),
                  ),
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
                      return Card(
                        child: ListTile(
                          title: Text(serviceName),
                        ),
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

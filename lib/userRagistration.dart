import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_service.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  TextEditingController cnicController = TextEditingController();
  File? livePhoto;
  bool isUploading = false;
  bool isVerified = false;

  Future<void> _captureLivePhoto() async {
    final picker = ImagePicker();  // Create an instance of ImagePicker
    final pickedFile = await picker.pickImage(source: ImageSource.camera);  // Use pickImage instead of getImage

    if (pickedFile != null) {
      setState(() {
        livePhoto = File(pickedFile.path);  // Assign the image file path
      });
    }
  }

  Future<void> _uploadData() async {
    setState(() {
      isUploading = true;
    });

    try {
      // Upload the live photo to Firebase Storage
      String livePhotoUrl = await FirebaseService.uploadImage(livePhoto!.path, 'live_photos');

      // Add user details to Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'cnic': cnicController.text,
        'livePhotoUrl': livePhotoUrl,
        'isVerified': false, // Initially not verified
      });

      setState(() {
        isVerified = false; // Initially not verified
        isUploading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User details uploaded successfully!'),
        ),
      );
    } catch (e) {
      // Handle errors
      print('Error uploading data: $e');
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: cnicController,
                decoration: InputDecoration(labelText: 'CNIC'),
              ),
              SizedBox(height: 16.0),
              livePhoto == null
                  ? ElevatedButton(
                onPressed: () {
                  _captureLivePhoto();
                },
                child: Text('Capture Live Photo'),
              )
                  : Image.file(
                livePhoto!,
                height: 150.0,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: isUploading ? null : () => _uploadData(),
                child: isUploading
                    ? CircularProgressIndicator()
                    : Text('Submit'),
              ),
              SizedBox(height: 16.0),
              Text('Verification Status: ${isVerified ? "Verified" : "Pending"}'),
            ],
          ),
        ),
      ),
    );
  }
}

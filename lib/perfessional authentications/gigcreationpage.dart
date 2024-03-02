import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';


class GigCreationPage extends StatefulWidget {
  @override
  _GigCreationPageState createState() => _GigCreationPageState();
}
class _GigCreationPageState extends State<GigCreationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  List<XFile> _selectedImages = []; // Track selected images

  bool _isLoading = false;
  Future<List<String>> _uploadImagesToStorage(List<XFile> images) async {
    List<String> imageUrls = [];

    try {
      for (var image in images) {
        // Generate a unique image name using Uuid
        String imageName = Uuid().v1();
        // Create a reference to the Firebase Storage location
        Reference ref = FirebaseStorage.instance.ref().child('images/$imageName');
        // Upload the image file to Firebase Storage
        await ref.putFile(File(image.path));
        // Get the download URL of the uploaded image
        String imageUrl = await ref.getDownloadURL();
        // Add the download URL to the list
        imageUrls.add(imageUrl);
      }
    } catch (error) {
      // Handle error uploading images
      print('Error uploading images: $error');
    }

    return imageUrls;
  }


  // Function to pick images
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles;
      });
    }
  }

  // Function to submit for approval
  Future<void> _submitForApproval() async {
    // Check if any gig is selected
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill in all fields and select images'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true when submission starts
    });

    try {
      final User user = _auth.currentUser!;
      // Upload images to Firebase Storage and get their download URLs
      List<String> imageUrls = await _uploadImagesToStorage(_selectedImages);
      // Save gig service details to Firestore
      await FirebaseFirestore.instance.collection('perfessionals').doc(user.uid).update({
        'gigs': FieldValue.arrayUnion([
          {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'location': _locationController.text,
            'price': _priceController.text,
            'gigimages': imageUrls,
            'gigstatus': 'pending', // Set initial status to pending for admin approval
            'createdAt': DateTime.now(), // Set creation time
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Gig submitted successfully'),
        ),
      );

      setState(() {
        _isLoading = false; // Set loading state to false when submission is successful
      });

      // Clear text fields and selected images after submission
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _priceController.clear();
      setState(() {
        _selectedImages.clear();
      });

      // Show success message or navigate to a different page
    } catch (error) {
      // Handle error
      setState(() {
        _isLoading = false; // Set loading state to false when submission fails
      });
      print('Error submitting gig: $error');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error submitting gig: $error'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Gig Service'),
      ),
      body: _isLoading // Check loading state
          ? Center(child: CircularProgressIndicator()) // Show loading indicator if true
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: null, // Allow multiple lines for description
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Select Images of Previous Work'),
            ),
            SizedBox(height: 20.0),
            _selectedImages.isEmpty
                ? SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      File(_selectedImages[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                SizedBox(height: 20.0),
              ],
            ),
            ElevatedButton(
              onPressed: _submitForApproval,
              child: Text('Submit for Approval'),
            ),
          ],
        ),
      ),
    );
  }
}






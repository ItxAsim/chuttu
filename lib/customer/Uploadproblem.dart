import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class ProblemUploadScreen extends StatefulWidget {
  @override
  _ProblemUploadScreenState createState() => _ProblemUploadScreenState();
}

class _ProblemUploadScreenState extends State<ProblemUploadScreen> {
  late File _image;
  final picker = ImagePicker();
  late List<File> _selectedImages = [];
  String _problemTitle = '';
  String _problemDescription = '';
  bool _uploading = false;

  Future getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _selectedImages.add(_image);
      });
    }
  }

  Future<void> _uploadProblem() async {
    setState(() {
      _uploading = true;
    });

    // Generate unique problem ID
    String problemId = FirebaseFirestore.instance.collection('problems').doc().id;

    // Get current user ID
    User? userId = FirebaseAuth.instance.currentUser;

    // Define the data to be uploaded
    Map<String, dynamic> problemData = {
      'problemId': problemId,
      'userId': userId?.uid,
      'title': _problemTitle,
      'status':'pending',
      'description': _problemDescription,
      'timestamp': FieldValue.serverTimestamp(), // Optional: Timestamp when the problem was uploaded
    };

    // Upload images to Firebase Storage
    List<String> imageUrls = await _uploadImages(problemId);

    // Add image URLs to the problem data
    problemData['imageUrls'] = imageUrls;

    try {
      // Upload problem data to Firestore
      await FirebaseFirestore.instance.collection('problems').doc(problemId).set(problemData);

      // Show success message or navigate to next screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Problem uploaded successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      // Handle upload errors
      print('Error uploading problem: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload problem. Please try again later.'),
        ),
      );
    } finally {
      // Clear the loading state
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<List<String>> _uploadImages(String problemId) async {
    List<String> imageUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      File imageFile = _selectedImages[i];

      // Create a reference to the image file in Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('problem_images')
          .child('$problemId')
          .child('${Path.basename(imageFile.path)}');

      // Upload image to Firebase Storage
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete and get the image URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Add image URL to the list
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Problem')),
      body: _uploading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    _problemTitle = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    _problemDescription = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              Text('Selected Images:'),
              SizedBox(height: 8.0),
              _selectedImages.isEmpty
                  ? Text('No images selected')
                  : SizedBox(
                height: 100.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Image.file(_selectedImages[index]),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => getImage(ImageSource.camera),
                    child: Text('Take Photo'),
                  ),
                  ElevatedButton(
                    onPressed: () => getImage(ImageSource.gallery),
                    child: Text('Choose from Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _uploadProblem,
                  child: Text('Upload Problem'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

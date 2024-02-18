import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late ImageProvider _image = AssetImage('images/placeholder.jpeg');
  late User? user;
  final picker = ImagePicker();
  TextEditingController _descriptionController = TextEditingController();
  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      user = user;
    });
  }
  Future getImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _image = FileImage(File(pickedFile.path)); // Use FileImage for selected file
      } else {
        print('No image selected.');
      }
    } catch (error) {
      // Handle image selection error here
      print(error);
    }
  }



  Future<void> uploadPost() async {
    if (_image == null) return;

    String imageUrl = '';
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('${DateTime.now()}.jpg');

    await storageReference.putFile(_image as File).whenComplete(() async {
      imageUrl = await storageReference.getDownloadURL();
    });

    FirebaseFirestore.instance.collection('posts').add({
      'imageUrl': imageUrl,
      'description': _descriptionController.text,
      'email': user?.email,
      'timestamp': Timestamp.now(),
    });

    Navigator.pop(context);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCurrentUser();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: [
            GestureDetector(
              onTap: getImage,
              child: Image(
                image: _image,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadPost,
              child: Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      final docRef =
      FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        setState(() {
          _fullname.text = userData?['name'] ?? '';
          _emailController.text = userData?['email'] ?? '';
          _address.text = userData?['address'] ?? '';
          _phoneNumber.text = userData?['phoneNumber'] ?? '';
          _profileImageUrl = userData?['profile_url'];
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImageUrl = pickedFile.path;
      });

      // Upload the image to Firebase Storage
      String userId = _currentUser!.uid;
      Reference ref = FirebaseStorage.instance.ref().child('user_profile_images/$userId.jpg');
      UploadTask uploadTask = ref.putFile(File(pickedFile.path));
      uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(userId).update({'profile_url': imageUrl});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImageUrl != null
                  ? FileImage(File(_profileImageUrl!))
                  : _currentUser?.photoURL != null
                  ? NetworkImage(_currentUser!.photoURL!) as ImageProvider<Object>
                  : null,
              child: _profileImageUrl == null && _currentUser?.photoURL == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            TextButton.icon(
              onPressed: () => _showImagePickerDialog(),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile Picture'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fullname,
              decoration: const InputDecoration(
                labelText: 'Name',
                enabled: false, // Disable editing
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                enabled: false, // Disable editing
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Address',
                enabled: false, // Disable editing
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneNumber,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                enabled: false, // Disable editing
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose image source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
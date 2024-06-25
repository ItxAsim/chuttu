import 'package:chuttu/perfessional%20authentications/perhome.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Documentverification extends StatefulWidget {
  @override
  _DocumentverificationState createState() => _DocumentverificationState();
}

class _DocumentverificationState extends State<Documentverification> {
  late String userId;
  late TextEditingController cnicController;
   File? frontCnicImage=null;
   File? backCnicImage=null;
  File? userpic=null;
  final picker = ImagePicker();
bool submission=false;
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
    cnicController = TextEditingController();
  }

  Future<void> _captureImage(bool isFront) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          frontCnicImage = File(pickedFile.path);
        } else {
          backCnicImage = File(pickedFile.path);
        }
      });
    }
  }
  Future<void> _captureImageuser() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {

          userpic = File(pickedFile.path);

      });
    }
  }

  bool _validateCnic(String cnic) {
    return cnic.length == 13 && int.tryParse(cnic) != null;
  }

  Future<void> _submitForApproval() async {
    String cnic = cnicController.text;
    if (!_validateCnic(cnic)) {
      // Show error message for invalid CNIC
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid CNIC. CNIC must be 13 digits.')),
      );
      return;
    }

    try {
      // Upload images to Firebase Storage
      setState(() {
        submission=true;
      });
      String frontImageUrl = ''; // Front CNIC image URL
      String backImageUrl = ''; // Back CNIC image URL
      String userpicurl = '';

      // Upload front CNIC image
      if (frontCnicImage != null) {
        String frontImageName = 'front_cnic_$userId';
        final frontImageRef = FirebaseStorage.instance.ref().child('cnic_images/$frontImageName.jpg');
        await frontImageRef.putFile(frontCnicImage!);
        frontImageUrl = await frontImageRef.getDownloadURL();
      }

      // Upload back CNIC image
      if (backCnicImage != null) {
        String backImageName = 'back_cnic_$userId';
        final backImageRef = FirebaseStorage.instance.ref().child('cnic_images/$backImageName.jpg');
        await backImageRef.putFile(backCnicImage!);
        backImageUrl = await backImageRef.getDownloadURL();
      }
      if (userpic != null) {
        String userpicname = 'userpic$userId';
        final userpicRef = FirebaseStorage.instance.ref().child('perfessional/$userpicname.jpg');
        await userpicRef.putFile(userpic!);
        userpicurl = await userpicRef.getDownloadURL();
      }

      // Add professional details to Firestore
      await FirebaseFirestore.instance.collection('perfessionals').doc(userId).update({
        'userId': userId,
        'cnic': cnic,
        'userpic':userpicurl ,
        'front_cnic_image_url': frontImageUrl,
        'back_cnic_image_url': backImageUrl,
        'status': 'pending', // Status for admin approval
        // Other professional details
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted for approval')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>perhome()));
      setState(() {
        submission=false;
      });
    } catch (e) {
      submission=false;
      // Show error message if submission fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text('Document Verification'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: cnicController,
              decoration: InputDecoration(labelText: 'CNIC (13 digits)'),
            ),
            SizedBox(height: 16.0),
            if (frontCnicImage != null) ...[
              Image.file(frontCnicImage!),
              SizedBox(height: 8.0),
            ],
            if (userpic != null) ...[
              Image.file(userpic!),
              SizedBox(height: 8.0),
            ],
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _captureImage(true),
                  child: Text('Capture Front CNIC'),
                ),
                ElevatedButton(
                  onPressed: () => _captureImage(false),
                  child: Text('Capture Back CNIC'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _captureImageuser(),
              child: Text('capture Proffessional image'),
            ),
            SizedBox(height: 16.0),
            if (backCnicImage != null) ...[
              Image.file(backCnicImage!),
              SizedBox(height: 8.0),
            ],
            ElevatedButton(
              onPressed: _submitForApproval,
              child: submission==true?CircularProgressIndicator():Text('Submit for Approval'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class AdminConsoleScreen extends StatefulWidget {
  @override
  _AdminConsoleScreenState createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  List<Map<String, dynamic>> userDataList = [];

  Future<void> fetchUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();

      // Clear existing data before updating with new data
      userDataList.clear();

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        userData['userId'] = document.id; // Add the document ID as a user ID
        userDataList.add(userData);
      });

      // Refresh the UI to reflect the updated data
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle errors here
    }
    FirebaseStorage storage = FirebaseStorage.instance;




  }


  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> getImageUrl() async {
    final ref = storage.ref('livePhotoUrl');
    final url = await ref.getDownloadURL();
    return url;
  }
  Future<void> updateVerificationStatus(String userId, bool isVerified) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isVerified': isVerified,
      });
      print('Verification status updated successfully.');
    } catch (e) {
      print('Error updating verification status: $e');
      // Handle errors here
    }
  }
 // Replace with your image path

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';

    Future<void> loadImage() async {
      imageUrl = await getImageUrl();
      setState(() {});
    }

    loadImage();
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Console'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display user data in a ListView
              if (userDataList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: userDataList.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> userData = userDataList[index];
                    return ListTile(
                      title: Text(userData['cnic']),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display live photo URL
                          Text('Live Photo:'),
                          imageUrl.isEmpty
                              ? Center(child: CircularProgressIndicator())
                              : Image.network(imageUrl)// Display the image
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await updateVerificationStatus(userData['userId'], true);
                          setState(() {
                            userData['isVerified'] = true;
                          });
                        },
                        child: Text('Verify'),
                      ),
                    );
                  },
                )
              else
                Text('No user data available'),
            ],
          ),
        ),
      ),
    );
  }
}

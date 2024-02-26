import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Approval'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('perfessionals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) => _buildListItem(context, documents[index]), // Pass context explicitly
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final cnicNumber = document['cnic'];
    final services = document['services'];
    final status = document['status'];
    final frontCnicUrl = document['front_cnic_image_url'];
    final backCnicUrl = document['back_cnic_image_url'];
    final userpicUrl = document['userpic'];

    return ExpansionTile(
      title: Text('Professional ID: ${document.id}'),
      subtitle: Text('Status: $status'),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CNIC Number: $cnicNumber'),
            Text('Services: ${services.join(', ')}'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () => _approveProfessional(document.id),
                ),
                IconButton(
                  icon: Icon(Icons.thumb_down),
                  onPressed: () => _rejectProfessional(document.id),
                ),
              ],
            ),
          ],
        ),
        if (frontCnicUrl != null || backCnicUrl != null)
          SizedBox(
            height: 150, // Adjust height as needed
            child: Row(
              children: [
                if (frontCnicUrl != null)
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, frontCnicUrl), // Pass context
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage(frontCnicUrl),
                        fit: BoxFit.cover,
                        // Handle image errors
                      ),
                    ),
                  ),
                if (backCnicUrl != null)
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, backCnicUrl), // Pass context
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage(backCnicUrl),
                        fit: BoxFit.cover,
                        // Handle image errors
                      ),
                    ),
                  ),
                if (userpicUrl != null)
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, userpicUrl), // Pass context
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage(frontCnicUrl),
                        fit: BoxFit.cover,
                        // Handle image errors
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
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

  void _approveProfessional(String professionalId) {
    // Update the status of the professional to 'approved' in Firestore
    FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).update({
      'status': 'approved',
    });
  }

        void _rejectProfessional(String professionalId) {
    // Update the status of the professional to 'rejected' in Firestore
    FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).update({
      'status': 'rejected',
    });
  }
}

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
            itemBuilder: (context, index) => _buildListItem(context, documents[index]),
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final cnicNumber = data.containsKey('cnic') ? data['cnic'] : '';
    final services = data.containsKey('services') ? data['services'] : [];
    final status = data.containsKey('status') ? data['status'] : '';
    final frontCnicUrl = data.containsKey('front_cnic_image_url') ? data['front_cnic_image_url'] : '';
    final backCnicUrl = data.containsKey('back_cnic_image_url') ? data['back_cnic_image_url'] : '';
    final userpicUrl = data.containsKey('userpic') ? data['userpic'] : '';

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
        if (frontCnicUrl.isNotEmpty || backCnicUrl.isNotEmpty || userpicUrl.isNotEmpty)
          SizedBox(
            height: 150,
            child: Row(
              children: [
                if (frontCnicUrl.isNotEmpty)
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, frontCnicUrl),
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage(frontCnicUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (backCnicUrl.isNotEmpty)
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, backCnicUrl),
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage(backCnicUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (userpicUrl.isNotEmpty)
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context, userpicUrl),
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage(userpicUrl),
                        fit: BoxFit.cover,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Image'),
          ),
          body: Center(
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _approveProfessional(String professionalId) {
    FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).update({
      'status': 'approved',
    });
  }

  void _rejectProfessional(String professionalId) {
    FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).update({
      'status': 'rejected',
    });
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GigApproval extends StatefulWidget {
  @override
  State<GigApproval> createState() => _GigApprovalState();
}

class _GigApprovalState extends State<GigApproval> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gig Approval'),
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
  Widget _buildListItem(BuildContext context, DocumentSnapshot gigData) {


    return ExpansionTile(
        title: Text(gigData['title']),
        subtitle: Text(gigData['description']),
        children: [
          Column(
            children: [
              Text("${gigData['price']}Rs"),
              Text(gigData['location']),
              Text(gigData['gigstatus']),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      setState(() {

                      });
                      _approveGig(gigData.id,context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      setState(() {

                      });
                      _rejectGig(gigData.id,context);
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 150, // Adjust height as needed
            child: Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showImageFullScreen(context,   gigData['images'][0] as String), // Pass context
                      child: FadeInImage(
                        placeholder: AssetImage('images/placeholder.jpeg'),
                        image: NetworkImage( gigData['gigimages'][0]  as String),
                        fit: BoxFit.cover,
                        // Handle image errors
                      ),
                    ),
                  ),
                ]
            ),
          ),
        ] );
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

  void _approveGig(String gigId, BuildContext context) {
    try {
      FirebaseFirestore.instance.collection('perfessionals').doc(gigId).update({
        'gigstatus': 'approved',
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving gig: $error'),
        ),
      );
      print('Error approving gig: $error');
    }
  }

  void _rejectGig(String gigId, BuildContext context) {
    try {
      FirebaseFirestore.instance.collection('perfessionals').doc(gigId).delete();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting gig: $error'),
        ),
      );
      print('Error rejecting gig: $error');
    }
  }
}

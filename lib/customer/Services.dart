import 'package:chuttu/customer/orderdetails.dart';
import 'package:chuttu/customer/proffesionalprofile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovedGigsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available services'),
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

          final List<DocumentSnapshot> professionals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              final professional = professionals[index];
              final professionalData = professional.data() as Map<String, dynamic>;
              final List<dynamic> gigs = professionalData['gigs'] ?? [];

              // Filter out only approved gigs
              final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();

              if (approvedGigs.isEmpty) {
                // If there are no approved gigs, don't show anything for this professional
                return SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      for (var i = 0; i < approvedGigs.length; i++)
                        Card(
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            title: Text(approvedGigs[i]['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${approvedGigs[i]['description']}'),
                                Text('Status: ${approvedGigs[i]['gigstatus']}'),
                                Text('Price: ${approvedGigs[i]['price']}'),
                                Text('Location: ${approvedGigs[i]['location']}'),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _orderGig(context,professional.id, i), // Access index in onPressed
                                      child: Text('Order'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _viewProfile(context,professional.id,), // Access index in onPressed
                                      child: Text('Profile view'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                // Display images
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: (gigs[i]['gigimages'] as List<dynamic>?)?.length ?? 0,
                                    itemBuilder: (context, imgIndex) {
                                      final imageUrl = gigs[i]['gigimages'][imgIndex];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Image.network(
                                          imageUrl,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _orderGig(BuildContext context, String professionalId, int gigId) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsScreen(professionalId: professionalId, gigindex: gigId, )));


  }

  void _viewProfile(BuildContext context, String professionalId) {
    // Navigate to the user profile page with the professional's ID
    // For example:
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfile(professionalId: professionalId),
    ),
     );
  }
}

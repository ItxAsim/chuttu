import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GigApproval extends StatelessWidget {
   int index1=0;
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

          final List<DocumentSnapshot> professionals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              final professional = professionals[index];
              final professionalData = professional.data() as Map<String, dynamic>;
              final List<dynamic> gigs = professionalData['gigs'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(professionalData['name']),
                    subtitle: Text(professionalData['phoneNumber']),
                  ),
                  Column(
                    children: [
                      for (var i = 0; i < gigs.length; i++)
                        Card(
                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            title: Text(gigs[i]['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${gigs[i]['description']}'),
                                Text('Status: ${gigs[i]['gigstatus']}'),
                                Text('Price: ${gigs[i]['price']}'),
                                Text('Location: ${gigs[i]['location']}'),
                                SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _approveGig(professional.id, i), // Access index in onPressed
                                      child: Text('Approve'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _rejectGig(professional.id, i), // Access index in onPressed
                                      child: Text('Reject'),
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

  Future<void> _approveGig(String professionalId, int? gigId) async {
    try {
      final DocumentSnapshot professionalDoc =
          await FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).get();

      if (professionalDoc.exists) {
        final List<dynamic> gigs = professionalDoc['gigs']?? [];

        if (gigId != null && gigId >= 0 && gigId < gigs.length) {
          gigs[gigId]['gigstatus'] = 'Approved';

          await FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).set({
            'gigs': gigs,
          },
              SetOptions(merge: true)
          );
        } else {
          print('Invalid gig ID or out of bounds.');
        }
      } else {
        print('Professional document not found.');
      }
    } catch (error) {
      print('Error updating gig status: $error');
    }
  }

  Future<void> _rejectGig(String professionalId, int? gigId) async {
    try {
      final DocumentSnapshot professionalDoc =
          await FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).get();

      if (professionalDoc.exists) {
        final List<dynamic> gigs = professionalDoc['gigs']?? [];

        if (gigId != null && gigId >= 0 && gigId < gigs.length) {
          gigs[gigId]['gigstatus'] = 'rejected';

          await FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).set({
            'gigs': gigs,
          },
              SetOptions(merge: true)
          );
        } else {
          print('Invalid gig ID or out of bounds.');
        }
      } else {
        print('Professional document not found.');
      }
    } catch (error) {
      print('Error updating gig status: $error');
    }
}
  }
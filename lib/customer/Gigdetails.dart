import 'package:chuttu/customer/proffesionalprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chatScreen.dart';

import 'orderdetails.dart';

class GigDetailsPage extends StatefulWidget {
  final Map<String, dynamic> gig;
  final String proffessionalId;
  final int gigindex;

  const GigDetailsPage({Key? key, required this.gig, required this.proffessionalId, required this.gigindex}) : super(key: key);

  @override
  State<GigDetailsPage> createState() => _GigDetailsPageState();
}

class _GigDetailsPageState extends State<GigDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final User? user;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    user=_auth.currentUser;
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gig['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display gig images and description here
              SizedBox(
                height: 250,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (widget.gig['gigimages'] as List<dynamic>?)?.length ?? 0,
                  itemBuilder: (context, imgIndex) {
                    final imageUrl = widget.gig['gigimages'][imgIndex];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        imageUrl,
                        width: screenWidth,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              Text(widget.gig['description']),
              // Add order button here
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _orderGig(context, widget.proffessionalId, widget.gigindex);
                      },
                      child: Text('Order'),
                    ),

                    SizedBox(width: 25,),
                    ElevatedButton(
                      onPressed: () {
                        _viewProfile(context, widget.proffessionalId);
                      },
                      child: Text('View Profile'),
                    ),
                    SizedBox(width: 25,),
                    ElevatedButton(
                      onPressed: () async {
                        // Fetch receiver details
                        final receiverSnapshot = await FirebaseFirestore.instance.collection('perfessionals').doc(widget.proffessionalId).get();
                        if (receiverSnapshot.exists) {
                          final receiverData = receiverSnapshot.data() as Map<String, dynamic>;
                          final receiverName = receiverData['name'];
                          final receiverProfileImageUrl = receiverData['profileImageUrl'];

                          // Navigate to chat screen with sender and receiver details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                senderId: user!.uid,
                                receiverId: widget.proffessionalId,
                                receiverName: receiverName,
                                receiverProfileImage: receiverProfileImageUrl,
                              ),
                            ),
                          );
                        } else {
                          // Handle receiver not found
                        }
                      },
                      child: Text('Chat'),
                    ),


                  ],
                ),
              ),
              // Add view user profile button here

            ],
          ),
        ),
      ),
    );
  }
  void _orderGig(BuildContext context, String professionalId, int gigId) async {
    try {
      // Handle order gig logic here
      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(professionalId: professionalId, gigindex: gigId, )));
    } catch (e) {
      print('Error ordering gig: $e');
      // Handle order gig errors
    }
  }


  void _viewProfile(BuildContext context, String professionalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfile(professionalId: professionalId),
      ),
    );
  }
}

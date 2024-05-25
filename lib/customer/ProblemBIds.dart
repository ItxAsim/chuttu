
import 'package:chuttu/customer/orderdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chatScreen.dart';

class ProblemBids extends StatefulWidget {
  final String problemId;

  ProblemBids({required this.problemId});

  @override
  _ProblemBidsState createState() => _ProblemBidsState();
}

class _ProblemBidsState extends State<ProblemBids> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<DocumentSnapshot>> _bidsStream;
  late final User? user;
  late final String professionalName;
  late final String Profileimage;

  @override
  void initState() {
    super.initState();
    _fetchBids();
    user = _auth.currentUser;
  }

  void _fetchBids() {
    _bidsStream = FirebaseFirestore.instance
        .collection('bids')
        .where('problemId', isEqualTo: widget.problemId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _acceptBid(DocumentSnapshot bid) {
    FirebaseFirestore.instance
        .collection('bids')
        .doc(bid.id)
        .update({'status': 'accepted'})
        .then((_) {
      FirebaseFirestore.instance.collection('problems').doc(widget.problemId).update({'status': 'accepted'});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsScreen(
            professionalId: bid['professionalId'],
            gigindex: 0,
          ),
        ),
      );
    }).catchError((error) {
      print('Error updating bid status: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bids on Problem'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _bidsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No bids available for this problem'),
            );
          }

          final List<DocumentSnapshot> bids = snapshot.data!;

          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              final String description = bid['description'];
              final double price = bid['price'];
              final String professionalId = bid['professionalId'];

              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('perfessionals').doc(professionalId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('Professional name not available');
                    }

                    final professionalData = snapshot.data!;
                    professionalName = professionalData['name'];
                    Profileimage=professionalData['profileImageUrl'];
                    return Text('Professional: $professionalName');
                  },
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: \$${price.toStringAsFixed(2)}'),
                    Text(description),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _acceptBid(bid),
                      child: Text('Accept'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            senderId: user!.uid,
                            receiverId: professionalId,
                            receiverName: professionalName, // Pass receiver name
                            receiverProfileImage: Profileimage, // Pass receiver profile image
                          ),
                        ),
                      ),
                      child: Text('Chat'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

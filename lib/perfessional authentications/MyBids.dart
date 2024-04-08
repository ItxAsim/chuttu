import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUserBids extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bids'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('professionalId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<DocumentSnapshot> bids = snapshot.data!.docs;

          if (bids.isEmpty) {
            return Center(child: Text('You have not placed any bids yet.'));
          }

          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index];
              final bidData = bid.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(bidData['description'] ?? ''),
                subtitle: Text('Price: \$${bidData['price']}'),
                trailing: Text('Status: ${bidData['status']}'),
              );
            },
          );
        },
      ),
    );
  }
}

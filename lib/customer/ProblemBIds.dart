import 'package:chuttu/customer/orderdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProblemBids extends StatefulWidget {
  final String problemId;

  ProblemBids({required this.problemId});

  @override
  _ProblemBidsState createState() => _ProblemBidsState();
}

class _ProblemBidsState extends State<ProblemBids> {
  late Stream<List<DocumentSnapshot>> _bidsStream;

  @override
  void initState() {
    super.initState();
    _fetchBids();
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
        .doc(bid.id) // Assuming bid document has an id field
        .update({'status': 'accepted'})
        .then((_) {
          FirebaseFirestore.instance.collection('problems').doc(widget.problemId).update({'status':'accepted'});
      // Navigate to order creation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsScreen(
            professionalId: bid['professionalId'], gigindex: 0,
            // Pass any other necessary data to the order creation screen
          ),
        ),
      );
    }).catchError((error) {
      print('Error updating bid status: $error');
    });
  }

  void _openChat(DocumentSnapshot bid) {
    // Implement chat functionality here
    print('Chat with professional: ${bid['professionalId']}');
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
                  future: FirebaseFirestore.instance
                      .collection('perfessionals') // Assuming professionals are stored in a 'users' collection
                      .doc(professionalId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('Professional name not available');
                    }

                    final professionalData = snapshot.data!;
                    final String professionalName = professionalData['name'];
                    return Text('Professional: $professionalName');
                  },
                ),
                subtitle: Column(
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
                      onPressed: () => _openChat(bid),
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

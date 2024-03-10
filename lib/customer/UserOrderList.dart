import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'RatingStar.dart';

class UserOrderList extends StatefulWidget {
  final String status;

  UserOrderList({Key? key, required this.status}) : super(key: key);

  @override
  State<UserOrderList> createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.status)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customer_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', isEqualTo: widget.status)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final List<DocumentSnapshot>? orders = snapshot.data?.docs;

          if (orders == null || orders.isEmpty) {
            return Center(child: Text('No ${widget.status} orders'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                child: ListTile(
                  title: Text('Order #${orders[index].id}'),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Customer: ${order['userName']}'),
                      Text('Phone number: ${order['phoneNumber']}'),
                      Text('Service Title: ${order['title']}'),
                      Text('Service Price: ${order['price']}'),
                      if(widget.status=='Completed')
                        ElevatedButton(onPressed: ()=> _showRatingDialog(context, order['professionalId'], orders[index].id), child: Text("Rate"))
                    ],

                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showRatingDialog(BuildContext context, String professionalId, String orderId) async {
    // Check if the customer has already rated the professional for this order
    bool hasRated = await _checkIfRated(orderId);

    if (hasRated) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Already Rated'),
            content: Text('You have already rated this professional for this order.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function if already rated
    }

    int workRating = 0;
    int attitudeRating = 0;
    int timeRating = 0;
    int professionalismRating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Rate Professional'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Work:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      5,
                          (index) => RatingStar(
                        rating: workRating,
                        value: index + 1,
                        onTap: (value) => setState(() => workRating = value),
                      ),
                    ),
                  ),
                  Text('Attitude:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      5,
                          (index) => RatingStar(
                        rating: attitudeRating,
                        value: index + 1,
                        onTap: (value) => setState(() => attitudeRating = value),
                      ),
                    ),
                  ),
                  Text('Time:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      5,
                          (index) => RatingStar(
                        rating: timeRating,
                        value: index + 1,
                        onTap: (value) => setState(() => timeRating = value),
                      ),
                    ),
                  ),
                  Text('Professionalism:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      5,
                          (index) => RatingStar(
                        rating: professionalismRating,
                        value: index + 1,
                        onTap: (value) => setState(() => professionalismRating = value),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Save ratings to Firestore
                    FirebaseFirestore.instance.collection('ratings').add({
                      'professionalId': professionalId,
                      'workRating': workRating,
                      'attitudeRating': attitudeRating,
                      'timeRating': timeRating,
                      'professionalismRating': professionalismRating,
                      'orderId': orderId,
                      'customerId': FirebaseAuth.instance.currentUser?.uid,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('rating submitted successfully!'),
                        ),);
                    Navigator.pop(context);
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _checkIfRated(String orderId) async {
    QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('orderId', isEqualTo: orderId)
        .where('customerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    return ratingSnapshot.docs.isNotEmpty;
  }
}

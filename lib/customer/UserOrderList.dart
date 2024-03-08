import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserOrderList extends StatelessWidget {
  final String status;

  UserOrderList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(status)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customer_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', isEqualTo: status)
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
            // Handle the case where there's no data
            return Center(child: Text('No $status orders'));
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
                      Text('Service Title : ${order['title']} '),
                      Text('Service Price : ${order['price']} ')


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

}
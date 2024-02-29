import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovedGigsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available serivces'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('perfessionals')
            .where('gigstatus', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final gigDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gigDocs.length,
            itemBuilder: (context, index) {
              final gigData = gigDocs[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(gigData['title']),
                  subtitle: Column(
                    children: [

                      Text(gigData['description']
                      ),
                      Text("Location: ${gigData['location']}"),
                      Text("Price:    ${gigData['price']}Rs"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Implement order functionality here
                      _placeOrder(context, gigData);
                    },
                    child: Text('Order'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _placeOrder(BuildContext context, Map<String, dynamic> gigData) {
    // Implement order placement logic here
    // You can navigate to another page to complete the order process
    // For example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => OrderPage(gigData: gigData)),
    // );
  }
}

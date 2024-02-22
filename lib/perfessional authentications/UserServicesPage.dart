import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Services'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('perfessionals')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final List<DocumentSnapshot<Map<String, dynamic>>>? documents =
            snapshot.data?.docs.cast<DocumentSnapshot<Map<String, dynamic>>>();
            return ListView.builder(
              itemCount: documents?.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic>? data = documents?[index].data();
                final List<String>? services = data?['services']?.cast<String>();
                final String? location = data?['location'] as String?;
                return ListTile(
                  title: Text('Services: ${services?.join(', ') ?? 'N/A'}'),
                  subtitle: Text('Location: ${location ?? 'N/A'}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

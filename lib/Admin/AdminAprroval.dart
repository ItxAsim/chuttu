import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Stream<QuerySnapshot> _servicesStream;

  @override
  void initState() {
    super.initState();
    _servicesStream = FirebaseFirestore.instance
        .collection('perfessionals')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> _approveService(String serviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('perfessionals')
          .doc(serviceId)
          .update({'status': 'Approved'});
    } catch (e) {
      print('Error approving service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _servicesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final serviceId = service.id;
              final userId = service['userId'];
              final serviceDetails = service['services'].join(', ');

              return ListTile(
                title: Text(serviceDetails),
                subtitle: Text('User ID: $userId'),
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    _approveService(serviceId);
                  },
                ),
              );
            },
          );
        },
      ),

    );
  }
}

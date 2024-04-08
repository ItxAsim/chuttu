import 'package:chuttu/perfessional%20authentications/PlaceBid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Problems'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('problems')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<DocumentSnapshot> problems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: problems.length,
            itemBuilder: (context, index) {
              final problem = problems[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(problem['title']),
                subtitle: Text(problem['description']),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Navigate to the place bid page and pass problemId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfessionalBidPage(problemId: problems[index].id),
                      ),
                    );
                  },
                  child: Text('Place Bid'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

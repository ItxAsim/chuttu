import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ProblemBIds.dart';

class UserUploadedProblems extends StatefulWidget {
  final String userId;

  UserUploadedProblems({required this.userId});

  @override
  _UserUploadedProblemsState createState() => _UserUploadedProblemsState();
}

class _UserUploadedProblemsState extends State<UserUploadedProblems> {
  late Stream<List<DocumentSnapshot>> _problemsStream;

  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  void _fetchProblems() {
    _problemsStream = FirebaseFirestore.instance
        .collection('problems')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Uploaded Problems'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _problemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No problems uploaded'),
            );
          }

          final List<DocumentSnapshot> problems = snapshot.data!;

          return ListView.builder(
            itemCount: problems.length,
            itemBuilder: (context, index) {
              final problem = problems[index];
              final String problemTitle = problem['title'];
              final String problemId = problem.id;

              return ListTile(
                title: Text(problemTitle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemBids(problemId: problemId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
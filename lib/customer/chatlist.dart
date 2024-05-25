import 'package:chuttu/chatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UserListScreencustumer extends StatefulWidget {
  const UserListScreencustumer({Key? key}) : super(key: key);

  @override
  _UserListScreencustumerState createState() => _UserListScreencustumerState();
}

class _UserListScreencustumerState extends State<UserListScreencustumer> {
  late Stream<List<Map<String, dynamic>>> _userListStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    _userListStream = CombineLatestStream.list([
      _firestore
          .collection('messages')
          .where('sender', isEqualTo: user?.uid)
          .snapshots(),
      _firestore
          .collection('messages')
          .where('receiver', isEqualTo: user?.uid)
          .snapshots()
    ]).asyncMap((snapshot) async {
      Set<String> userIds = {};
      List<Map<String, dynamic>> usersData = [];

      List<QueryDocumentSnapshot> allDocs = snapshot.expand((querySnapshot) => querySnapshot.docs).toList();

      for (var doc in allDocs) {
        final userId = doc['receiver'] == user?.uid ? doc['sender'] : doc['receiver'];
        if (!userIds.contains(userId)) {
          userIds.add(userId);
          final userSnapshot = await _firestore.collection('perfessionals').doc(userId).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>;
            usersData.add({
              'userId': userId,
              'name': userData['name'],
              'email': userData['email'],
              'profileImageUrl': userData['profileImageUrl'],
            });
          }
        }
      }
      return usersData;
    });
  }

  Widget _buildUserItem(Map<String, dynamic> userData) {
    return ListTile(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(userData['profileImageUrl']),
          ),
          SizedBox(width: 10),
          Text(userData['name']),
        ],
      ),
      subtitle: Text(userData['email']),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              senderId: user!.uid,
              receiverId: userData['userId'],
              receiverName: userData['name'], // Pass receiver name
              receiverProfileImage: userData['profileImageUrl'], // Pass receiver profile image URL
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _userListStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Map<String, dynamic>> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index];
              return _buildUserItem(userData);
            },
          );
        },
      ),
    );
  }
}

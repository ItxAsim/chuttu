import 'package:chuttu/perfessional%20authentications/ChatScreenProffessional.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../customer/ChatScreen.dart';

class UserListScreen extends StatefulWidget {
  final String professionalId;

  UserListScreen({required this.professionalId});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Stream<List<Map<String, dynamic>>> _userListStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _userListStream = _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: widget.professionalId)
        .snapshots()
        .asyncMap((snapshot) async {
      Set<String> userIds = {};
      List<Map<String, dynamic>> usersData = [];
      for (var doc in snapshot.docs) {
        final userId = doc['senderId'];
        if (!userIds.contains(userId)) {
          userIds.add(userId);
          final userSnapshot = await _firestore.collection('users').doc(userId).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>;
            usersData.add({
              'userId': userId,
              'name': userData['name'],
              'email': userData['email'],
              'profileImageUrl': userData['profileImageUrl'],
              // Add other user data fields you want to include
            });
          }
        }
      }
      return usersData;
    });
  }

  Widget _buildUserItem(Map<String, dynamic> userData) {
    return ListTile(
      title: Row(children: [
        CircleAvatar(
          backgroundImage: NetworkImage(userData['profileImageUrl']),
        ),
        Text(userData['name'])]),
      subtitle: Text(userData['email']),
      // Add other user data fields as needed
      onTap: () {
        // Navigate to chat screen with this user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreenpro(userId: userData['userId'], professionalId:widget.professionalId,

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


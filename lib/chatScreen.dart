import 'dart:convert';

import 'package:chuttu/perfessional%20authentications/userRecieverprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'Notification_Services.dart';
import 'auth_services.dart';
import 'customer/proffesionalprofile.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName; // Receiver name
  final String receiverProfileImage; // Receiver profile image URL
  ChatScreen({super.key, required this.senderId, required this.receiverId, required this.receiverName, required this.receiverProfileImage,});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   bool user=false;
   final NotificationServices _notificationServices = NotificationServices();
   final AuthService _authService = AuthService();
  @override
void initState() {
    // TODO: implement initState
    super.initState();
    checkuserexist();
  }
  void checkuserexist()
  async {
    DocumentSnapshot receiverSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.receiverId).get();
    if(receiverSnapshot.exists)
    {
      setState(() {
        user=true;
      });

    }
  }
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<void> sendMessage(String message) async {
     if (message.isNotEmpty) {
       // Add message to Firestore collection
       await _firestore.collection('messages').add({
         'text': message,
         'sender': widget.senderId,
         'receiver': widget.receiverId,
         'timestamp': FieldValue.serverTimestamp(),
         'status': 'delivered',
       });
       _controller.clear();

       // Fetch device tokens for the receiver
       List<String> deviceTokens = [];
       var tokenSnapshot = await _firestore.collection('pushtokens').doc(widget.receiverId).get();

       if (tokenSnapshot.exists && tokenSnapshot.data() != null) {
         deviceTokens = List<String>.from(tokenSnapshot.data()!['tokens']);
       }

       if (deviceTokens.isEmpty) {
         print('No device tokens found for receiver');
         return;
       }

       // Fetch access token
       String accessToken = await _authService.getAccessToken();

       // Send notifications to all device tokens
       for (String deviceToken in deviceTokens) {
         var data = {
           'message': {
             'token': deviceToken,
             'notification': {
               'title': widget.receiverName,
               'body': message,
             },
             'android': {
               'notification': {
                 'notification_count': 1,
               },
             },
             'data': {
               'type': 'msj',
               'user':user,
               'id': 'dummy_id',
             }
           }
         };

         var response = await http.post(
           Uri.parse('https://fcm.googleapis.com/v1/projects/chuttu-29802/messages:send'),
           body: jsonEncode(data),
           headers: {
             'Content-Type': 'application/json; charset=UTF-8',
             'Authorization': 'Bearer $accessToken',
           },
         );

         // Optionally, handle the response
         if (response.statusCode == 200) {
           print('Notification sent successfully to $deviceToken');
         } else {
           print('Failed to send notification to $deviceToken: ${response.body}');
         }
       }
     }
   }


   void markAsRead(DocumentSnapshot document) {
    if (document['status'] == 'delivered' && document['receiver'] == widget.senderId) {
      _firestore.collection('messages').doc(document.id).update({'status': 'read'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  InkWell(
          onTap: ()=>{
            user?Navigator.push(context,
                MaterialPageRoute(builder: (context)=>uerReciverProfile(userId: widget.receiverId,))):
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>ProfessionalProfile(professionalId: widget.receiverId,)))
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.receiverProfileImage),
              ),
              SizedBox(width: 10),
              Text(widget.receiverName),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: CombineLatestStream.list([
                _firestore
                    .collection('messages')
                    .where('sender', isEqualTo: widget.senderId)
                    .where('receiver', isEqualTo: widget.receiverId)
                    .orderBy('timestamp') // Default is ascending order
                    .snapshots(),
                _firestore
                    .collection('messages')
                    .where('sender', isEqualTo: widget.receiverId)
                    .where('receiver', isEqualTo: widget.senderId)
                    .orderBy('timestamp') // Default is ascending order
                    .snapshots(),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot> messages = snapshot.data!
                    .expand((querySnapshot) => querySnapshot.docs)
                    .toList()
                  ..sort((a, b) {
                    Timestamp aTimestamp = a['timestamp'] ?? Timestamp.now();
                    Timestamp bTimestamp = b['timestamp'] ?? Timestamp.now();
                    return aTimestamp.compareTo(bTimestamp);
                  });

                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['text'];
                  final messageSender = message['sender'];
                  final messageReceiver = message['receiver'];
                  final messageStatus = message['status'];

                  final messageWidget = MessageBubble(
                    sender: messageSender,
                    text: messageText,
                    isMe: widget.senderId == messageSender,
                    status: messageStatus,
                  );

                  if (messageReceiver == widget.senderId) {
                    markAsRead(message);
                  }

                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final String status;

  MessageBubble({required this.sender, required this.text, required this.isMe, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15.0,
                    ),
                  ),
                  if(isMe)
                  Text(
                    status == 'delivered' ? 'Delivered' : 'Read',
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black38,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreenpro extends StatefulWidget {
  final String userId;
  final String professionalId;

  ChatScreenpro({required this.userId, required this.professionalId});

  @override
  _ChatScreenproState createState() => _ChatScreenproState();
}

class _ChatScreenproState extends State<ChatScreenpro> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _messagesStream;
  String professionalName = '';
  String professionalProfilePic = '';

  @override
  void initState() {
    super.initState();
    _fetchProfessionalData();
    _messagesStream = _firestore
        .collection('messages')
        .where('(senderId == ${widget.userId} && receiverId == ${widget.professionalId}) || (senderId == ${widget.professionalId} && receiverId == ${widget.userId})')
        .orderBy('timestamp')
        .snapshots();
    // Listen for changes in the 'messages' collection
    _firestore.collection('messages').snapshots().listen((snapshot) {
      for (var message in snapshot.docs) {
        if (message['receiverId'] == widget.professionalId && !message['seen']) {
          // Update the 'seen' field to true for messages sent to the current user
          message.reference.update({'seen': true});
        }
      }
    });
  }

  void _fetchProfessionalData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          professionalName = snapshot['name'];
          professionalProfilePic = snapshot['profileImageUrl'];
        });
      } else {
        print('Professional data not found');
      }
    }).catchError((error) {
      print('Error fetching professional data: $error');
    });
  }

  void _sendMessage(String message) {
    _firestore.collection('messages').add({
      'text': message,
      'senderId': widget.professionalId,
      'receiverId': widget.userId,
      'timestamp': Timestamp.now(),
      'seen': false,
      'delivered': true,
    });
    _textController.clear();
  }

  Widget _buildMessageItem(DocumentSnapshot message) {
    final String text = message['text'];
    final String senderId = message['senderId'];
    final Timestamp timestamp = message['timestamp'];
    final bool isUserMessage = senderId == widget.professionalId; // Check if the message is sent by the user
    final bool isVoiceMessage = (message.data() as Map<String, dynamic>).containsKey('voiceMessageUrl');
    final bool isSeen = message['seen'];

    // Update the 'seen' status when the message is also seen
    if (isSeen && !isUserMessage) {
      message.reference.update({'seen': true});
    }

    // Check if the 'delivered' field exists before accessing its value
    bool isDelivered = false;
    if ((message.data() as Map<String, dynamic>).containsKey('delivered')) {
      isDelivered = message['delivered'];
    }

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: isUserMessage ? Radius.circular(8.0) : Radius.circular(0),
            topRight: isUserMessage ? Radius.circular(0) : Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUserMessage ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              timestamp.toDate().toString(),
              style: TextStyle(
                fontSize: 12.0,
                color: isUserMessage ? Colors.white70 : Colors.black54,
              ),
            ),
            if (isUserMessage) // Only show 'seen' status for messages sent by the professional
              Text(
                isSeen ? 'Seen' : 'Delivered',
                style: TextStyle(
                  fontSize: 12.0,
                  color: isUserMessage ? Colors.white70 : Colors.black54,
                ),
              ),

          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(professionalProfilePic),
            ),
            SizedBox(width: 10),
            Text(professionalName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                stream: _messagesStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No messages found.'),
                    );
                  } else {
                    final messages = snapshot.data!.docs;
                    List<Widget> messageWidgets = [];
                    for (var message in messages) {
                      messageWidgets.add(_buildMessageItem(message));
                    }
                    return ListView(
                      children: messageWidgets,
                    );
                  }
                },
              )


          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _sendMessage(_textController.text);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    // Implement voice messaging
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

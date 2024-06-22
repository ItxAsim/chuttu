import 'package:chuttu/Notification_Services.dart';
import 'package:chuttu/perfessional%20authentications/MyBids.dart';
import 'package:chuttu/perfessional%20authentications/Userlist.dart';
import 'package:chuttu/perfessional%20authentications/bottomNavigationPerfessional.dart';
import 'package:chuttu/perfessional%20authentications/listProblem.dart';
import 'package:chuttu/perfessional%20authentications/usergig.dart';
import 'package:chuttu/selctionpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chatScreen.dart';
class perhome extends StatefulWidget {
  const perhome({super.key});

  @override
  State<perhome> createState() => _perhomeState();
}

class _perhomeState extends State<perhome> {
  @override
  final User? _user = FirebaseAuth.instance.currentUser;
  late final String _userId;
  int _selectedIndex=0;
  NotificationServices notificationServices=NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    _userId = _user?.uid ?? '';

    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) { print('token');
    print(value);
    FirebaseFirestore.instance
        .collection('pushtokens')
        .doc(_userId)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        // Token exists in Firestore, add new token to the array if it's not already there
        List<dynamic> tokens = docSnapshot.data()?['tokens'] ?? [];
        if (!tokens.contains(value)) {
          tokens.add(value);
          FirebaseFirestore.instance
              .collection('pushtokens')
              .doc(_userId)
              .update({
            'tokens': tokens,
            'updatedAt': DateTime.now(),
          });
        }
      } else {
        // Token doesn't exist in Firestore, so create an array and store the new token
        FirebaseFirestore.instance
            .collection('pushtokens')
            .doc(_userId)
            .set({
          'tokens': [value],
          'createdAt': DateTime.now(),
        });
      }
    });



    }
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pop(context);// Close the drawer
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Selectionpage()),
            (route) => false,
      );
      // Navigate to the sign-in page or any other page as needed
    } catch (e) {

      print('Error signing out: $e');
      // Handle sign-out errors
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
        backgroundColor: Colors.blueGrey,

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
      ListTile(
        title: Text('My Gigs'),
        trailing: Icon(Icons.shop),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>UserGigPage()));

        }),
            ListTile(
                title: Text('Place Bid'),
                trailing: Icon(Icons.handyman),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProblemListPage()));

                }),
            ListTile(
                title: Text('Chat'),
                trailing: Icon(Icons.chat),

                onTap: () {
                  String professionalId=FirebaseAuth.instance.currentUser!.uid;
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>UserListScreen(professionalId:professionalId )));

                }),
            ListTile(
                title: Text('My Bid'),
                trailing: Icon(Icons.card_travel),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CurrentUserBids()));

                }),
            ListTile(
              title: Text('Sign Out'),
              trailing: Icon(Icons.exit_to_app),
              onTap: () {
                _signOut(context);
                Navigator.pop(context);

              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('professionalId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final List<DocumentSnapshot> orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return Center(child: Text('No pending orders'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text('Order #${orders[index].id}'), // Display order ID
                  subtitle: Column(
                    children: [
                      Text('Customer: ${order['userName']}'),
                      Text('Customer Phone number: ${order['phoneNumber']}'),
                      Text('Details: ${order['details']}'),
                      Text('payment: ${order['payment']}'??''),
                      Text("Adress: ${order['location']}"),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(onPressed: () async {

                           DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(order['customer_id']).get();
                             Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
                             Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(senderId: order['professionalId'], receiverId: order['customer_id'], receiverName: userData['name'], receiverProfileImage: userData['profileImageUrl'],)
                             ));
                          }, child: Text('Chat')),
                          ElevatedButton(
                            onPressed: () => _acceptOrder(orders[index].id),
                            child: Text('Accept'),
                          ),
                          SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () => _rejectOrder(orders[index].id),
                            child: Text('Reject'),
                          ),
                        ],
                      ),


                    ],
                  ), // Assuming customer name is stored in the order
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Perbottomnavigation(
    items: [
    BottomNavigationBarItem(
    icon: Icon(Icons.home ),
    label: 'home',),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: 'create gig',
      ),
    BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'DASHBOARD',
    ),

    ],
    selectedIndex: _selectedIndex,
    ),
    );
  }
  void _acceptOrder(String orderId) {
    // Update order status to 'Accepted' in Firestore
    updateOrderStatus(orderId, 'Accepted');
  }

  void _rejectOrder(String orderId) {
    // Update order status to 'Rejected' in Firestore
    updateOrderStatus(orderId, 'Rejected');
  }

  // Example of how to change order status in Firestore
  void updateOrderStatus(String orderId, String newStatus) {
    try {
      FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (error) {
      print('Error updating order status: $error');
    }
  }
}

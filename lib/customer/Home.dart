import 'package:chuttu/customer/chatlist.dart';
import 'package:chuttu/customer/orderdetails.dart';
import 'package:chuttu/customer/proffesionalprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Gigdetails.dart';
import 'UserUploadedProblem.dart';


class ApprovedGigsPage extends StatefulWidget {
  @override
  State<ApprovedGigsPage> createState() => _ApprovedGigsPageState();
}

class _ApprovedGigsPageState extends State<ApprovedGigsPage> {
  int _selectedIndex = 0;
  final User? _user = FirebaseAuth.instance.currentUser;
  late final String _userId;
  late  String proffessionlId;
  @override
  void initState() {
    super.initState();
    _userId = _user?.uid ?? '';
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pop(context); // Close the drawer
      // Navigate to the sign-in page or any other page as needed
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign-out errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuttu'),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Show Services'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApprovedGigsPage()),
              );
            },
          ),
          ListTile(
            title: const Text('My uploaded Probelms'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserUploadedProblems(userId: _userId)),
              );
            },
          ),
          ListTile(
            title: Text("Chat"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>UserListScreencustumer()));
            },
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              _signOut(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('perfessionals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<DocumentSnapshot> professionals = snapshot.data!.docs;

        return SingleChildScrollView(
          child: GridView.count(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling of GridView
            shrinkWrap: true, // Wrap the GridView in a SingleChildScrollView
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            children: professionals.expand((professional) {
              final professionalData = professional.data() as Map<String, dynamic>;
              final List<dynamic> gigs = professionalData['gigs'] ?? [];
              proffessionlId=professionalData['userId'];
              final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();
              return _buildGigCards(context, approvedGigs);
            }).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _buildGigCards(BuildContext context, List<dynamic> approvedGigs) {
    List<Widget> gigCards = [];

    for (int i = 0; i < approvedGigs.length; i++) {
      final gig = approvedGigs[i];
      final List<dynamic> gigImages = gig['gigimages'] ?? [];

      gigCards.add(
        GestureDetector(
          onTap: () {
            _showGigDetails(context, gig, i); // Pass the gig index
          },
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gig['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 131,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gigImages.length,
                      itemBuilder: (context, imgIndex) {
                        final imageUrl = gigImages[imgIndex];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(
                            imageUrl,
                            width: 140,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  Text('Price: ${gig['price']} Rupees'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return gigCards;
  }


  void _showGigDetails(BuildContext context, Map<String, dynamic> gig, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GigDetailsPage(gig: gig, proffessionalId: proffessionlId,  gigindex: index,),
      ),
    );
  }




  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'HOME',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add),
          label: 'ADD POST',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'PROFILE',
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
    );
  }


}
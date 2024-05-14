import 'package:chuttu/customer/orderdetails.dart';
import 'package:chuttu/customer/proffesionalprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'UserUploadedProblem.dart';
import 'bottomnavigation.dart';

class ApprovedGigsPage extends StatefulWidget {
  @override
  State<ApprovedGigsPage> createState() => _ApprovedGigsPageState();
}

class _ApprovedGigsPageState extends State<ApprovedGigsPage> {
  int _selectedIndex = 0;
  final User? _user = FirebaseAuth.instance.currentUser;
  late final String _userId;

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

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: professionals.length,
          itemBuilder: (context, index) {
            final professional = professionals[index];
            final professionalData = professional.data() as Map<String, dynamic>;
            final List<dynamic> gigs = professionalData['gigs'] ?? [];

            // Filter out only approved gigs
            final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();

            if (approvedGigs.isEmpty) {
              // If there are no approved gigs, don't show anything for this professional
              return const SizedBox.shrink();
            }

            return Wrap(
                children: [for (var i = 0; i < approvedGigs.length; i++)
                  _buildGigCard(context, professional.id, i, approvedGigs[i]),
                ]
            );
          },
        );
      },
    );
  }

  Widget _buildGigCard(BuildContext context, String professionalId, int gigId, Map<String, dynamic> gig) {
    return Card(

      child: ListTile(
        title: Text(gig['title'],style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (gig['gigimages'] as List<dynamic>?)?.length ?? 0,
                itemBuilder: (context, imgIndex) {
                  final imageUrl = gig['gigimages'][imgIndex];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      imageUrl,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            /* Text('Description: ${gig['description']}'),*/
            Row(
              children: [
                Text('Price: ${gig['price']} Rupees'),
                /*     SizedBox(width: 10,),
                Text('Location: ${gig['location']}',),*/
              ],
            ),

            /* const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _orderGig(context, professionalId, gigId),
                  child: const Text('Order'),
                ),
                ElevatedButton(
                  onPressed: () => _viewProfile(context, professionalId),
                  child: const Text('Profile view'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Display images*/

          ],
        ),
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

  void _orderGig(BuildContext context, String professionalId, int gigId) async {
    try {
      // Handle order gig logic here
      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(professionalId: professionalId, gigindex: gigId, )));
    } catch (e) {
      print('Error ordering gig: $e');
      // Handle order gig errors
    }
  }

  void _viewProfile(BuildContext context, String professionalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfile(professionalId: professionalId),
      ),
    );
  }
}
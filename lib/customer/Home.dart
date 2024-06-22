import 'dart:convert';

import 'package:chuttu/Notification_Services.dart';
import 'package:chuttu/customer/chatlist.dart';
import 'package:chuttu/customer/orderdetails.dart';
import 'package:chuttu/customer/proffesionalprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../shownotification.dart';
import 'Gigdetails.dart';
import 'UserUploadedProblem.dart';
import 'bottomnavigation.dart';
import 'package:http/http.dart' as http;

class ApprovedGigsPage extends StatefulWidget {
  @override
  State<ApprovedGigsPage> createState() => _ApprovedGigsPageState();
}

class _ApprovedGigsPageState extends State<ApprovedGigsPage> {
  int _selectedIndex = 0;
  final User? _user = FirebaseAuth.instance.currentUser;
  late final String _userId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  NotificationServices notificationServices=NotificationServices();

  @override
  void initState() {
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

    setState(() {
      _selectedIndex = 0;
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuttu'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white70,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Container(
            width: screenWidth, // Match the screen width
            height: screenHeight, // Match the screen height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/designbg.png"),
                fit: BoxFit.fill, // Stretch to fill the entire screen
              ),
            ),
          ),
          Column(
            children: [
              _buildTitlesList(),
              Expanded(child: _buildBody()),
            ],
          ),
        ],
      ),
      bottomNavigationBar: bottomnavigation(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
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
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey,
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
            title: const Text('My uploaded Problems'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserUploadedProblems(userId: _userId)),
              );
            },
          ),
          ListTile(
            title: const Text('show notification'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => shownotification())
              );
            },
          ),
          ListTile(
            title: Text("Chat"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserListScreencustumer()));
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

  Widget _buildTitlesList() {
    return Container(
      height: 50,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('perfessionals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<DocumentSnapshot> professionals = snapshot.data!.docs;
          final List<String> gigTitles = [];

          professionals.forEach((professional) {
            final professionalData = professional.data() as Map<String, dynamic>;
            final List<dynamic>? gigs = professionalData['gigs'];
            if (gigs != null) {
              final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();
              approvedGigs.forEach((gig) {
                final gigTitle = gig['title']?.toString() ?? '';
                gigTitles.add(gigTitle);
              });
            }
          });

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gigTitles.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = gigTitles[index];
                  });
                },
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      gigTitles[index],
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
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
        final List<Widget> gigCards = [];

        professionals.forEach((professional) {
          final professionalData = professional.data() as Map<String, dynamic>;
          final List<dynamic>? gigs = professionalData['gigs'];
          final String professionalId = professionalData['userId']?.toString() ?? '';
          if (gigs != null) {
            final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();

            final filteredGigs = approvedGigs.where((gig) {
              final gigTitle = gig['title']?.toString().toLowerCase() ?? '';
              final searchQuery = _searchQuery.toLowerCase();
              return gigTitle.contains(searchQuery);
            }).toList();

            gigCards.addAll(_buildGigCards(context, filteredGigs, professionalId));
          }
        });

        return SingleChildScrollView(
          child: GridView.count(
            physics: NeverScrollableScrollPhysics(), // Disable scrolling of GridView
            shrinkWrap: true, // Wrap the GridView in a SingleChildScrollView
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            children: gigCards,
          ),
        );
      },
    );
  }

  List<Widget> _buildGigCards(BuildContext context, List<dynamic> approvedGigs, String professionalId) {
    List<Widget> gigCards = [];

    for (int i = 0; i < approvedGigs.length; i++) {
      final gig = approvedGigs[i];
      final List<dynamic>? gigImages = gig['gigimages'];
      gigCards.add(
        GestureDetector(
          onTap: () {
            _showGigDetails(context, gig, professionalId, i); // Pass the gig index and professionalId
          },
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gig['title']?.toString() ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 131,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gigImages?.length ?? 0,
                      itemBuilder: (context, imgIndex) {
                        final imageUrl = gigImages?[imgIndex]?.toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: 140,
                            height: 130,
                            fit: BoxFit.cover,
                          )
                              : Container(),
                        );
                      },
                    ),
                  ),
                  Text('Price: ${gig['price']?.toString() ?? ''} Rupees'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return gigCards;
  }

  void _showGigDetails(BuildContext context, Map<String, dynamic> gig, String professionalId, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GigDetailsPage(gig: gig, proffessionalId: professionalId, gigindex: index,),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
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
        final List<Widget> gigCards = [];

        professionals.forEach((professional) {
          final professionalData = professional.data() as Map<String, dynamic>;
          final List<dynamic>? gigs = professionalData['gigs'];
          final String professionalId = professionalData['userId']?.toString() ?? '';
          if (gigs != null) {
            final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();

            final filteredGigs = approvedGigs.where((gig) {
              final gigTitle = gig['title']?.toString().toLowerCase() ?? '';
              final searchQuery = query.toLowerCase();
              return gigTitle.contains(searchQuery);
            }).toList();

            gigCards.addAll(_buildGigCards(context, filteredGigs, professionalId));
          }
        });

        return ListView(
          children: gigCards,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
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
        final List<Widget> suggestionList = [];

        professionals.forEach((professional) {
          final professionalData = professional.data() as Map<String, dynamic>;
          final List<dynamic>? gigs = professionalData['gigs'];
          final String professionalId = professionalData['userId']?.toString() ?? '';
          if (gigs != null) {
            final List<dynamic> approvedGigs = gigs.where((gig) => gig['gigstatus'] == 'Approved').toList();

            final filteredGigs = approvedGigs.where((gig) {
              final gigTitle = gig['title']?.toString().toLowerCase() ?? '';
              final searchQuery = query.toLowerCase();
              return gigTitle.contains(searchQuery);
            }).toList();

            suggestionList.addAll(_buildGigCards(context, filteredGigs, professionalId));
          }
        });

        return ListView(
          children: suggestionList,
        );
      },
    );
  }

  List<Widget> _buildGigCards(BuildContext context, List<dynamic> approvedGigs, String professionalId) {
    List<Widget> gigCards = [];

    for (int i = 0; i < approvedGigs.length; i++) {
      final gig = approvedGigs[i];
      final List<dynamic>? gigImages = gig['gigimages'];

      gigCards.add(
        GestureDetector(
          onTap: () {
            _showGigDetails(context, gig, professionalId, i); // Pass the gig index and professionalId
          },
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gig['title']?.toString() ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 131,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gigImages?.length ?? 0,
                      itemBuilder: (context, imgIndex) {
                        final imageUrl = gigImages?[imgIndex]?.toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: 140,
                            height: 130,
                            fit: BoxFit.cover,
                          )
                              : Container(),
                        );
                      },
                    ),
                  ),
                  Text('Price: ${gig['price']?.toString() ?? ''} Rupees'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return gigCards;
  }

  void _showGigDetails(BuildContext context, Map<String, dynamic> gig, String professionalId, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GigDetailsPage(gig: gig, proffessionalId: professionalId, gigindex: index),
      ),
    );
  }
}

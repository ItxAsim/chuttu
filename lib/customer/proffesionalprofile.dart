import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfessionalProfile extends StatefulWidget {
  final String professionalId;

  ProfessionalProfile({required this.professionalId});

  @override
  State<ProfessionalProfile> createState() => _ProfessionalProfileState();
}

class _ProfessionalProfileState extends State<ProfessionalProfile> {

  double averageRating = 0.0;
  int totalOrdersCompleted = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfessionalData();
  }
  Future<void> _fetchProfessionalData() async {
    await _fetchAverageRating();
    await _fetchTotalOrdersCompleted();
  }

  Future<void> _fetchAverageRating() async {
    QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('professionalId', isEqualTo: widget.professionalId)
        .get();

    if (ratingSnapshot.docs.isNotEmpty) {
      double totalRating = 0.0;
      int numberOfRatings = 0;

      ratingSnapshot.docs.forEach((doc) {
        totalRating +=
            doc['workRating'] + doc['attitudeRating'] + doc['timeRating'] + doc['professionalismRating'];
        numberOfRatings += 4; // Counting four ratings per document
      });

      setState(() {
        averageRating = totalRating / numberOfRatings;
      });
    }
  }

  Future<void> _fetchTotalOrdersCompleted() async {
    QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('professionalId', isEqualTo: widget.professionalId)
        .where('status', isEqualTo: 'Completed')
        .get();

    setState(() {
      totalOrdersCompleted = ordersSnapshot.docs.length;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('perfessionals').doc(widget.professionalId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final professionalData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract professional information
          final String name = professionalData['name'] ?? '';
          final String phoneNumber = professionalData['phoneNumber'] ?? '';
          final String profileImageUrl = professionalData['profileImageUrl'] ?? '';
          final double rating = professionalData['rating'] ?? 0.0;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Name: $name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.call),
                    title: Text(
                      'Phone Number: $phoneNumber',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Average Rating: ',
                            style: TextStyle(fontSize: 20),
                          ),
                          _buildRatingStars(averageRating),
                        ],
                      ),
                  SizedBox(height: 20),
                  Text(
                    'Total Orders Completed: $totalOrdersCompleted',
                    style: TextStyle(fontSize: 20),
                  ),


                SizedBox(height: 20),
                    ],
                  ),
          )
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(
        5,
            (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.yellow[700],
          size: 30,
        ),
      ),
    );
  }
}


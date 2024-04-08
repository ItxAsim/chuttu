import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String professionalId;
  final int gigindex;



  OrderDetailsScreen({required this.professionalId, required this.gigindex,});



  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  get professionalId => professionalId;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {


    bool isLoading = false;
    String userName = ''; // Variables to store order details
    String phoneNumber = ''; // Initialize with empty strings
    String location = '';
    String title='';
    String price='';
    String details='';



    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Your Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => userName = value, // Update userName when user types
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phoneNumber = value, // Update phoneNumber when user types
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) => location = value, // Update location when user types
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Details'),
                onChanged: (value) => details = value, // Update location when user types
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true); // Set loading state

                  try {
                    final User? user=_auth.currentUser;
                    final DocumentSnapshot professionalDoc =
                    await FirebaseFirestore.instance
                        .collection('perfessionals')
                        .doc(widget.professionalId)
                        .get();
    if (professionalDoc.exists) {
      final List<dynamic> gigs = professionalDoc['gigs'] ?? [];
        title = gigs[widget.gigindex]['title'];
       price = gigs[widget.gigindex]['price'];
    }


    // Add unique identifier for each order
                    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

                    // Add order to Firestore
                    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
                      'id': orderId, // Unique order identifier
                      'customer_id':user?.uid,
                      'customer_email':user?.email,
                      'userName': userName,
                      'phoneNumber': phoneNumber,
                      'location': location,
                      'title': title,
                      'price': price,
                      'details':details,
                      'status':'pending',
                      'professionalId': widget.professionalId,
                      'gigindex': widget.gigindex,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    // Show success message and clear user details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Order submitted successfully!'),
                      ),
                    );


                    setState(() {
                      userName = ''; // Clear user details after successful order
                      phoneNumber = '';
                      location = '';
                    });
                    Navigator.pop(context);
                  } catch (error) {
                    // Handle errors
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('An error occurred: $error'),

                      ),

                    );
                  } finally {
                    setState(() => isLoading = false); // Reset loading state
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator() // Show progress indicator
                    : Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:chuttu/perfessional%20authentications/Document%20verification.dart';
import 'package:chuttu/perfessional%20authentications/bottomNavigationPerfessional.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'GoogleMap.dart';
import 'UserServicesPage.dart';

class ProfessionalServicesPage extends StatefulWidget {
  @override
  _ProfessionalServicesPageState createState() =>
      _ProfessionalServicesPageState();
}

class _ProfessionalServicesPageState extends State<ProfessionalServicesPage> {
  Set<String> selectedServices = {};
  int _selectedIndex = 0;
  late LatLng selectedLocation = LatLng(0, 0);
  final List<String> serviceOptions = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _selectLocation(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }

  Future<void> _submitServicesForApproval() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('perfessionals').doc(user.uid).update({
          'userId': user.uid,
          'services': selectedServices.toList(),
          'location': GeoPoint(selectedLocation.latitude, selectedLocation.longitude),
          'status': 'pending',
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Documentverification(),
          ),
        );
      }
    } catch (e) {
      print('Error submitting services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Services'),
      ),
      body: ListView(
        children: [
          ListView.builder(
            shrinkWrap: true, // Ensure the ListView takes only the necessary space
            itemCount: serviceOptions.length,
            itemBuilder: (context, index) {
              final service = serviceOptions[index];
              return ListTile(
                title: Text(service),
                onTap: () {
                  setState(() {
                    if (selectedServices.contains(service)) {
                      selectedServices.remove(service);
                    } else {
                      selectedServices.add(service);
                    }
                  });
                },
                trailing: selectedServices.contains(service)
                    ? Icon(Icons.check)
                    : null,
              );
            },
          ),
          // Add more service options here
          ListTile(
            title: Text('Select Location'),
            onTap: () {
              // Navigate to Google Maps page for location selection
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapSelectionPage(
                    onLocationSelected: _selectLocation,
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: /*selectedLocation != LatLng(0, 0) &&*/
                selectedServices.isNotEmpty
                ? _submitServicesForApproval
                : null,
            child: Text('Submit for Approval'),
          ),
        ],

      ),
      bottomNavigationBar: Perbottomnavigation(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person ),
            label: 'Dashboard',),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'ADD Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_moderator_rounded),
            label: 'admin',
          ),
        ],
        selectedIndex: _selectedIndex,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}
class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng( 32.26286000 ,74.66327000 ); // Default position (Pasrur)
  String _currentAddress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selectedAddress = await showSearch<String?>(
                context: context,
                delegate: LocationSearchDelegate(
                  onLocationSelected: (location) async {
                    final latLng = LatLng(location.latitude, location.longitude);
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: latLng,
                          zoom: 14.0,
                        ),
                      ),
                    );
                    _currentPosition = latLng;
                    _currentAddress = await _getAddressFromLatLng(latLng);
                    setState(() {});
                  },
                ),
              );
              if (selectedAddress != null) {
                setState(() {
                  _currentAddress = selectedAddress;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (position) async {
              _currentPosition = position;
              _currentAddress = await _getAddressFromLatLng(position);
              setState(() {});
            },
          ),
          Center(
            child: Icon(Icons.pin_drop, color: Colors.red, size: 40),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _currentAddress);
              },
              child: Text('Select this location'),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Text(_currentAddress),
          ),
        ],
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}";
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return '';
  }
}

class LocationSearchDelegate extends SearchDelegate<String?> {
  final Function(LatLng)? onLocationSelected;

  LocationSearchDelegate({this.onLocationSelected});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Location>>(
      future: locationFromAddress(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        } else {
          final locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return FutureBuilder<List<Placemark>>(
                future: placemarkFromCoordinates(location.latitude, location.longitude),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  } else if (snapshot.hasError) {
                    return ListTile(title: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListTile(title: Text('No results found'));
                  } else {
                    final placemarks = snapshot.data!;
                    final placemark = placemarks.first;
                    return ListTile(
                      title: Text('${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.postalCode?? ''}, ${placemark.country?? ''}'),
                      onTap: () {
                        if (onLocationSelected!= null) {
                          onLocationSelected!(LatLng(location.latitude, location.longitude));
                        }
                        close(context, '${placemark.street?? ''}, ${placemark.locality?? ''}, ${placemark.postalCode?? ''}, ${placemark.country?? ''}');
                      },
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
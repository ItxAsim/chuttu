import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapSelectionPage extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  MapSelectionPage({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late GoogleMapController mapController;
  late LatLng selectedLocation = LatLng(0, 0); // Default location
  LocationData? currentLocation;

  Location location = Location();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        selectedLocation = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
    widget.onLocationSelected(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: currentLocation != null
          ? GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTapped,
        initialCameraPosition: CameraPosition(
          target: selectedLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('currentLocation'),
            position: selectedLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


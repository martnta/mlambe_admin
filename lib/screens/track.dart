import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../directions_repo.dart';
import '../models/directions.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  final double? latitude;
  final double? longitude;

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late final double? latitude;
  late final double? longitude;
  late Marker _destination;
  bool _shouldShowDialog = true;

  @override
  void initState() {
    super.initState();
    latitude = widget.latitude;
    longitude = widget.longitude;
    //initialisation
    _destination = Marker(
      markerId: MarkerId('Destination'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: LatLng(latitude!, longitude!), // Destination coordinates
    );
  }

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-15.798283, 35.005829), // Blantyre, Malawi
    zoom: 11.5,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  // late Marker _destination;
  Directions? _info = null;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mlambe Emergency'),
        actions: [
          if (_origin != null)
            TextButton(
                onPressed: () => _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: _origin!.position, zoom: 14.4, tilt: 50.0),
                      ),
                    ),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                child: const Text('START')),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: _destination.position, zoom: 14.4, tilt: 50.0),
                ),
              ),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600)),
              child: const Text('DEST'),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination,
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.purpleAccent,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
          ),

          //display total distance and ETA

          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0))
                    ]),
                child: Text(
                  '${_info?.totalDistance}, ${_info?.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }

//getting current location with geolocator

  void _getCurrentLocation() async {
    try {
      print("getting location...");
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Current position: $currentPosition");

      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
        );
      });

      // Show a dialog to ask the user whether to start tracking the destination
      if (_shouldShowDialog) {
        _shouldShowDialog = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Start Tracking?'),
              content:
                  const Text('Do you want to start tracking the destination?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _startTrackingDestination(); // Start tracking
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Optionally, you can handle not starting tracking here
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
      // Handle other errors (e.g., Geolocator errors)
    }
  }

//tracking method
  void _startTrackingDestination() async {
    try {
      _shouldShowDialog = true;
      final directions = await DirectionsRepository().getDirections(
        origin: _origin?.position,
        destination: _destination.position,
      );

      if (directions != null) {
        setState(() {
          _info = directions;
        });
        _googleMapController.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
              : CameraUpdate.newCameraPosition(_initialCameraPosition),
        );
      } else {
        // Handle directions fetch failure
        _showDirectionFetch();
      }
    } catch (e) {
      print('Error: $e');
      // Handle other errors
      showErrorDialog('Error fetching directions: $e');
    }
  }

  void _showDirectionFetch() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _shouldShowDialog = true;
        return AlertDialog(
          title: const Text('Start Tracking Destination?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Do you want to start tracking the destination?'),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ETA: ${_info?.totalDistance}'),
                  Text(
                    ' Distance: ${_info?.totalDuration}',
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Position:'),
                  Text(
                    '${_origin?.position.latitude}, ${_origin?.position.longitude}',
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Destination:'),
                  Text(
                    '${_destination.position.latitude}, ${_destination.position.longitude}',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _startTrackingDestination(); // Start tracking
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Optionally, you can handle not starting tracking here
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

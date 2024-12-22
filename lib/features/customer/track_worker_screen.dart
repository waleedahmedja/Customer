import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackWorkerScreen extends StatefulWidget {
  final String workerId; // Pass the worker's UID

  const TrackWorkerScreen({super.key, required this.workerId});

  @override
  State<TrackWorkerScreen> createState() => _TrackWorkerScreenState();
}

class _TrackWorkerScreenState extends State<TrackWorkerScreen> {
  late GoogleMapController _mapController;
  LatLng _currentWorkerLocation = const LatLng(37.7749, -122.4194); // Default location
  bool _isWorkerAvailable = true;
  bool _isLoading = true; // Tracks initial loading state
  String _lastUpdated = "Unknown"; // Tracks the last updated time

  BitmapDescriptor? _customMarker; // Custom worker marker

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _listenToWorkerLocation();
  }

  /// Loads a custom marker icon
  void _loadCustomMarker() async {
    _customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/worker_icon.png',
    );
  }

  /// Listens to the worker's real-time location updates from Firestore
  void _listenToWorkerLocation() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.workerId)
        .snapshots()
        .listen((DocumentSnapshot doc) {
      if (!doc.exists || doc.data() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker data is unavailable.')),
        );
        return;
      }

      var data = doc.data() as Map<String, dynamic>;
      if (data['location'] != null) {
        GeoPoint location = data['location'];
        setState(() {
          _currentWorkerLocation = LatLng(location.latitude, location.longitude);
          _isWorkerAvailable = data['isAvailable'] ?? true;

          // Update the last updated time
          var timestamp = data['lastUpdated'] as Timestamp?;
          _lastUpdated = timestamp != null
              ? "${timestamp.toDate().hour}:${timestamp.toDate().minute}"
              : "Unknown";

          _isLoading = false; // Stop loading
        });

        // Animate the map to the updated location
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_currentWorkerLocation),
        );
      }
    });
  }

  /// Builds the Google Map widget
  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _currentWorkerLocation,
        zoom: 14,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('worker'),
          position: _currentWorkerLocation,
          icon: _customMarker ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: "Worker's Location",
            snippet: _isWorkerAvailable
                ? "Worker is online\nLast Updated: $_lastUpdated"
                : "Worker is offline",
          ),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Worker")),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildGoogleMap(),
          if (!_isWorkerAvailable)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Worker is currently offline",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

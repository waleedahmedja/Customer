import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late GoogleMapController _mapController;
  final LatLng _currentLocation = const LatLng(37.7749, -122.4194);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<Marker> _workerMarkers = {};
  StreamSubscription<QuerySnapshot>? _workerListener;

  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _subscribeToWorkers();
  }

  @override
  void dispose() {
    _workerListener?.cancel();
    super.dispose();
  }

  void _subscribeToWorkers() {
    _workerListener = _firestore
        .collection('users')
        .where('role', isEqualTo: 'worker')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      Set<Marker> markers = {};
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data['location'] != null) {
          GeoPoint geoPoint = data['location'];
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              infoWindow: InfoWindow(title: data['name'] ?? 'Worker'),
            ),
          );
        }
      }
      setState(() {
        _workerMarkers.clear();
        _workerMarkers.addAll(markers);
      });
    });
  }

  Future<void> _cancelJob(String jobId) async {
    setState(() => _isCancelling = true);
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': 'cancelled',
        'cancellationReason': 'Customer cancelled before acceptance.',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job cancelled successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling job: $e')),
      );
    } finally {
      setState(() => _isCancelling = false);
    }
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return "${placemarks.first.street}, ${placemarks.first.locality}";
    } catch (e) {
      return "Location not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown-customer';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 14),
              markers: _workerMarkers,
            ),
          ),
          Expanded(
            flex: 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('jobs')
                  .where('customerId', isEqualTo: customerId)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jobs = snapshot.data?.docs ?? [];
                if (jobs.isEmpty) {
                  return const Center(child: Text("No active jobs to cancel."));
                }

                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text("Job: ${job['jobType']}"),
                      subtitle: Text("Fare: \$${job['fare'] ?? 'N/A'}"),
                      trailing: ElevatedButton(
                        onPressed: _isCancelling ? null : () => _cancelJob(jobs[index].id),
                        child: _isCancelling
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Cancel"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

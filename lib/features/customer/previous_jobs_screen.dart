import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class PreviousJobsScreen extends StatefulWidget {
  const PreviousJobsScreen({super.key});

  @override
  State<PreviousJobsScreen> createState() => _PreviousJobsScreenState();
}

class _PreviousJobsScreenState extends State<PreviousJobsScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final customerId = _auth.currentUser?.uid ?? 'unknown-customer';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Previous Jobs"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('customerId', isEqualTo: customerId)
            .where('status', isEqualTo: 'completed')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No previous jobs found."));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index].data() as Map<String, dynamic>;
              return FutureBuilder<String>(
                future: _getAddressFromLatLng(
                    job['location'].latitude, job['location'].longitude),
                builder: (context, addressSnapshot) {
                  return _buildJobCard(job, addressSnapshot.data ?? "Unknown location");
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Fetches the human-readable address from coordinates
  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      return "${placemarks.first.street}, ${placemarks.first.locality}";
    } catch (e) {
      return "Location not found";
    }
  }

  /// Builds a reusable card for each job
  Widget _buildJobCard(Map<String, dynamic> job, String address) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: $address",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16.0)),
            const SizedBox(height: 8.0),
            Text("Fare: \$${job['fare'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.green)),
            Text("Payment Status: ${job['paymentStatus'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.blueGrey)),
            if (job['customerNotes'] != null && job['customerNotes'].isNotEmpty)
              Text("Notes: ${job['customerNotes']}",
                  style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8.0),
            if (job['workerRating'] != null)
              Row(
                children: [
                  const Text("Worker Rating:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4.0),
                  _buildRatingStars(job['workerRating']),
                ],
              ),
            if (job['completedAt'] != null)
              Text(
                "Completed At: ${_formatTimestamp(job['completedAt'])}",
                style: const TextStyle(color: Colors.black54, fontSize: 14.0),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(dynamic rating) {
    int stars = rating?.toInt() ?? 0;
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: Colors.orange,
          size: 18.0,
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute}";
  }
}

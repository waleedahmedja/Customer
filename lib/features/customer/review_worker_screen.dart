import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewWorkerScreen extends StatefulWidget {
  final String workerId;
  final String jobId;

  const ReviewWorkerScreen({
    super.key,
    required this.workerId,
    required this.jobId,
  });

  @override
  State<ReviewWorkerScreen> createState() => _ReviewWorkerScreenState();
}

class _ReviewWorkerScreenState extends State<ReviewWorkerScreen> {
  double _rating = 3.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  /// Submits the review to Firestore
  Future<void> _submitReview() async {
    final customerId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown-customer';

    if (_rating < 3.0 && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a comment for low ratings.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.workerId)
          .update({
        'reviews': FieldValue.arrayUnion([
          {
            'customerId': customerId,
            'rating': _rating,
            'comment': _commentController.text.trim(),
            'timestamp': Timestamp.now(),
          }
        ]),
      });

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({'reviewed': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review. Please try again later.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Builds the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Worker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rate the worker:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStarRating(),
            Text(
              "Rating: ${_rating.toInt()}",
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Leave a comment:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: "Write your feedback here",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Review"),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the star rating input
  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 32.0,
          ),
        );
      }),
    );
  }
}

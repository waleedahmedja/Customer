import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookJobScreen extends StatefulWidget {
  const BookJobScreen({super.key});

  @override
  State<BookJobScreen> createState() => _BookJobScreenState();
}

class _BookJobScreenState extends State<BookJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobDetailsController = TextEditingController();
  LatLng? _selectedLocation;
  String _jobType = 'cleaning';
  String _workerGender = 'any';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Job Type',
                  value: _jobType,
                  items: const [
                    DropdownMenuItem(value: 'cleaning', child: Text('Cleaning')),
                    DropdownMenuItem(value: 'gardening', child: Text('Gardening')),
                    DropdownMenuItem(value: 'carwash', child: Text('Carwash')),
                  ],
                  onChanged: (value) => setState(() => _jobType = value!),
                ),
                const SizedBox(height: 20),

                _buildDropdown(
                  label: 'Worker Gender Preference',
                  value: _workerGender,
                  items: const [
                    DropdownMenuItem(value: 'any', child: Text('Any')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (value) => setState(() => _workerGender = value!),
                ),
                const SizedBox(height: 20),

                const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextFormField(
                  controller: _jobDetailsController,
                  decoration: const InputDecoration(hintText: 'Provide details'),
                  validator: (value) => value == null || value.isEmpty ? 'Please provide job details' : null,
                ),
                const SizedBox(height: 20),

                const Text('Select Job Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildGoogleMap(),
                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitJob,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Submit Job'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Select $label',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        onTap: (LatLng position) => setState(() => _selectedLocation = position),
        markers: {
          if (_selectedLocation != null)
            Marker(markerId: const MarkerId('selected'), position: _selectedLocation!)
        },
        initialCameraPosition: const CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
      ),
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown-user';
      await FirebaseFirestore.instance.collection('jobs').add({
        'jobType': _jobType,
        'workerGender': _workerGender,
        'jobDetails': _jobDetailsController.text.trim(),
        'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'customerId': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job submitted successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

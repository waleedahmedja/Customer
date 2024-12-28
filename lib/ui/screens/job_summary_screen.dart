import 'package:flutter/material.dart';

class JobSummaryScreen extends StatelessWidget {
  const JobSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final worker = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Summary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selected Worker",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(worker['imageUrl']!),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker['name']!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          worker['rating']!,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Job Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Service: Deep Clean",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Date: 25th Dec 2023",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Time: 10:00 AM",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Submit job logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Job successfully submitted!")),
                );
              },
              child: const Text("Confirm & Submit"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class JobSummaryScreen extends StatelessWidget {
  final String workerName;
  final String workerPhone;

  const JobSummaryScreen({
    required this.workerName,
    required this.workerPhone,
    super.key,
  });

  Future<void> _cancelJob(BuildContext context) async {
    try {
      // Example: Update job status in Firestore
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc('JOB_ID') // Replace with actual job ID
          .update({'status': 'canceled'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job canceled successfully.")),
      );

      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel job: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("You selected: $workerName"),
            SizedBox(height: 8),
            Text("Contact: $workerPhone"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _cancelJob(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Cancel Job"),
            ),
          ],
        ),
      ),
    );
  }
}

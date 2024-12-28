import 'package:flutter/material.dart';
import '../widgets/worker_card.dart';

class WorkerListScreen extends StatelessWidget {
  const WorkerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock worker data
    final workers = [
      {
        'name': 'John Doe',
        'rating': '4.8',
        'imageUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      },
      {
        'name': 'Jane Smith',
        'rating': '4.7',
        'imageUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
      },
      {
        'name': 'Mark Johnson',
        'rating': '4.5',
        'imageUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Workers"),
      ),
      body: ListView.builder(
        itemCount: workers.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final worker = workers[index];
          return WorkerCard(
            name: worker['name']!,
            rating: worker['rating']!,
            imageUrl: worker['imageUrl']!,
            onSelect: () {
              Navigator.pushNamed(context, '/job-summary', arguments: worker);
            },
          );
        },
      ),
    );
  }
}

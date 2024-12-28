import 'package:flutter/material.dart';

class WorkerCard extends StatelessWidget {
  final String name;
  final String rating;
  final String imageUrl;
  final VoidCallback onSelect;

  const WorkerCard({
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSelect,
              child: const Text("Select"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class WorkerCard extends StatelessWidget {
  final String workerName;
  final String workerPhone; // New field for phone number
  final double rating;
  final VoidCallback onSelect;

  const WorkerCard({
    required this.workerName,
    required this.workerPhone,
    required this.rating,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(workerName),
        subtitle: Row(
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 18),
            SizedBox(width: 4),
            Text("$rating"),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: Text("Select"),
        ),
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (context) => _workerDetailsModal(context),
        ),
      ),
    );
  }

  Widget _workerDetailsModal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Worker Details", style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 8),
          Text("Name: $workerName"),
          Text("Phone: $workerPhone"), // Show worker phone
          Text("Rating: $rating"),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSelect();
            },
            child: Text("Select This Worker"),
          ),
        ],
      ),
    );
  }
}

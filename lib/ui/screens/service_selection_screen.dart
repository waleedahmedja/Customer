import 'package:flutter/material.dart';
import '../widgets/service_card.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Service")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ServiceCard(
              label: "Deep Clean",
              icon: Icons.cleaning_services,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/worker-list');
              },
            ),
            ServiceCard(
              label: "Clean",
              icon: Icons.local_laundry_service,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/worker-list');
              },
            ),
            ServiceCard(
              label: "Gardening",
              icon: Icons.grass,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/worker-list');
              },
            ),
            ServiceCard(
              label: "Car Wash",
              icon: Icons.directions_car,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/worker-list');
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyPolicyCard extends StatelessWidget {
  final Function() onAccept;

  const PrivacyPolicyCard({required this.onAccept, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "We value your privacy and process your personal information to provide a better experience. "
              "For more details, please read our full privacy policy.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                // Navigate to full privacy policy
              },
              child: const Text(
                "Read Privacy Policy",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Accept"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

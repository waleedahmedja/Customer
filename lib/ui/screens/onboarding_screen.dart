import 'package:flutter/material.dart';
import '../widgets/privacy_policy_card.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: PrivacyPolicyCard(
          onAccept: () {
            Navigator.pushNamed(context, '/service-selection');
          },
        ),
      ),
    );
  }
}

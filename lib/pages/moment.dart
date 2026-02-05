import 'package:flutter/material.dart';

class MomentPage extends StatelessWidget {
  const MomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pikachu'),
      ),
      body: const Center(
        child: Text('Hello, Moment!'),
      ),
    );
  }
}

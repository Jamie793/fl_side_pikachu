import 'package:flutter/material.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pikachu'),
      ),
      body: const Center(
        child: Text('Hello, Mine!'),
      ),
    );
  }
}

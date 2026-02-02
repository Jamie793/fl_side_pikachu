import 'package:flutter/material.dart';
import 'package:Pikachu/pages/webview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pikachu')),
      body: const WebViewPage(url: 'https://www.pixiv.net'),
    );
  }
}

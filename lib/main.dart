import 'package:flutter/material.dart';
import 'package:pikachu/pages/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/pages/pages.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/app',
      routes: {
        '/app': (context) => const AppPage(),
        '/detail': (context) => const DetailPage(),
      },
    );
  }
}

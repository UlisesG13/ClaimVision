import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ClaimVision',
      home: Scaffold(body: Center(child: Text('ClaimVision App'))),
    );
  }
}

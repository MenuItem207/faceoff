import 'package:client/src/config.dart/colours.dart';
import 'package:flutter/material.dart';

/// page for home
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.baseColour,
      body: Text('logged in'),
    );
  }
}

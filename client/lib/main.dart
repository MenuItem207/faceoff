import 'package:flutter/material.dart';
import 'package:client/src/config.dart/scroll.dart';
import 'package:client/src/views/login_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: ScrollBehaviour(),
          child: child!,
        );
      },
      home: const LoginPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:client/src/controllers/globals/global_socket_controller.dart';
import 'package:client/src/config.dart/colours.dart';

/// page for home
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.baseColour,
      body: ValueListenableBuilder<bool>(
        valueListenable: globalSocketController.isDeviceOnlineNotifier,
        builder: (context, isDeviceOnline, child) => Text(
          isDeviceOnline ? 'connected' : 'device disconnected',
        ),
      ),
    );
  }
}

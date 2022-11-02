import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/env.dart';

/// the global instance of the [GlobalSocketController]
GlobalSocketController globalSocketController = GlobalSocketController();

/// global controller that handles sockets
class GlobalSocketController {
  /// the socket.io instance
  final Socket socket = io(
    socketServerAddress,
    OptionBuilder()
        .setTransports(['websocket'])
        .enableForceNewConnection()
        .disableAutoConnect()
        .build(),
  );

  /// the current device ID
  int? deviceID;

  /// notifier for [isDeviceOnline]
  ValueNotifier<bool> isDeviceOnlineNotifier = ValueNotifier(true);

  /// whether or not the device is online
  bool get isDeviceOnline => isDeviceOnlineNotifier.value;

  /// updates the value of [isDeviceOnline]
  void updateIsDeviceOnline(bool newValue) {
    isDeviceOnlineNotifier.value = newValue;
  }

  /// the current state of the device (unlocked (0), locked (1), disabled (2), unknown (3))
  int deviceState = 3;

  /// the security profiles
  List securityProfiles = [];

  /// call to connect socket
  void connectSocket(
    int newDeviceID,
    void Function() onConnectionSuccesful,
  ) {
    deviceID = newDeviceID;

    socket.connect();

    socket.onDisconnect((data) => onSocketDisconnected());

    socket.on('device_event_reconnect', (data) => updateIsDeviceOnline(true));

    socket.on('device_event_disconnect', (data) => updateIsDeviceOnline(false));

    socket.emitWithAck(
      'client_init',
      {'device_id': deviceID},
      ack: (data) {
        updateIsDeviceOnline(data['is_device_online']);
        deviceState = data['device_locked_state'];
        securityProfiles = data['profiles'];
        print('data $data');
        onConnectionSuccesful();
      },
    );
  }

  /// call to disconnect socket
  void disconnectSocket() {
    socket.disconnect();
    onSocketDisconnected();
  }

  /// call on socket disconnected
  void onSocketDisconnected() {
    deviceID = null;
    updateIsDeviceOnline(false);
    deviceState = 3;
    securityProfiles = [];
  }
}

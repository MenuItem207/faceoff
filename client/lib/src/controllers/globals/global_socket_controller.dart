import 'package:client/env.dart';
import 'package:socket_io_client/socket_io_client.dart';

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

  /// whether or not the device is online
  bool isDeviceOnline = true;

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

    socket.emitWithAck(
      'client_init',
      {'device_id': deviceID},
      ack: (data) {
        isDeviceOnline = data['is_device_online'];
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
    isDeviceOnline = false;
    deviceState = 3;
    securityProfiles = [];
  }
}

import 'dart:async';

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

  /// notifier for [deviceState]
  ValueNotifier<int> deviceStateNotifier = ValueNotifier(3);

  /// the current state of the device (unlocked (0), locked (1), disabled (2), unknown (3))
  int get deviceState => deviceStateNotifier.value;

  /// updates the value of [deviceState]
  void updateDeviceState(int newState) {
    deviceStateNotifier.value = newState;
  }

  /// notifier for [securityProfiles]
  ValueNotifier<List> securityProfilesNotifier = ValueNotifier([]);

  /// the security profiles
  List get securityProfiles => securityProfilesNotifier.value;

  /// updates the value of [securityProfiles]
  void updateSecurityProfiles(List newSecurityProfiles) {
    print('updating $newSecurityProfiles');
    securityProfilesNotifier.value = newSecurityProfiles;
    securityProfilesNotifier.notifyListeners();
  }

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

    socket.on(
      'device_event_update_state',
      (data) => updateDeviceState(
        data['new_lock_state'],
      ),
    );

    socket.emitWithAck(
      'client_init',
      {'device_id': deviceID},
      ack: (data) {
        updateIsDeviceOnline(data['is_device_online']);
        updateDeviceState(data['device_locked_state']);
        updateSecurityProfiles(data['profiles']);
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
    updateDeviceState(3);
    updateSecurityProfiles([]);
  }

  /// sends a create user profile event
  Future sendCreateUserProfileEvent(
    String name,
    String url,
  ) async {
    Map updatedSecurityProfilesData = await sendSocketEvent(
      'client_event',
      {
        'event': 'client_event_modify_security_profile',
        'type': 'add',
        'name': name,
        'img_url': url,
        'device_id': deviceID,
      },
    );
    updateSecurityProfiles(updatedSecurityProfilesData['security_profiles']);
  }

  /// sends a update user profile event
  Future sendUpdateUserProfileEvent(
    String name,
    String url,
    int id,
  ) async {
    Map updatedSecurityProfilesData = await sendSocketEvent(
      'client_event',
      {
        'event': 'client_event_modify_security_profile',
        'type': 'update',
        'name': name,
        'img_url': url,
        'device_id': deviceID,
        'id': id,
      },
    );
    updateSecurityProfiles(updatedSecurityProfilesData['security_profiles']);
  }

  /// sends a delete user profile event
  Future sendDeleteUserProfileEvent(int id) async {
    Map updatedSecurityProfilesData = await sendSocketEvent(
      'client_event',
      {
        'event': 'client_event_modify_security_profile',
        'type': 'delete',
        'id': id,
        'device_id': deviceID,
      },
    );
    updateSecurityProfiles(updatedSecurityProfilesData['security_profiles']);
  }

  /// sends a update device state event
  Future sendUpdateDeviceStateEvent(int newState) async {
    Map updatedStateData = await sendSocketEvent(
      'client_event',
      {
        'event': 'client_event_update_lock_state',
        'device_id': deviceID,
        'new_lock_state': newState,
      },
    );
    updateDeviceState(updatedStateData['new_lock_state']);
  }

  /// sends a socket event and awaits reponse
  Future sendSocketEvent(
    String eventTitle,
    Map eventData,
  ) async {
    final Completer completer = Completer();
    Map? socketResponse;
    socket.emitWithAck(
      eventTitle,
      eventData,
      ack: (response) {
        completer.complete();
        socketResponse = response;
      },
    );
    await completer.future;
    return socketResponse!;
  }
}

import 'package:client/src/controllers/pages/home_page_controller.dart';
import 'package:client/src/views/widgets/home_page/security_profiles.dart';
import 'package:flutter/material.dart';
import 'package:client/src/config.dart/text_styles.dart';
import 'package:client/src/views/widgets/button_widget.dart';
import 'package:client/src/controllers/globals/global_socket_controller.dart';
import 'package:client/src/config.dart/colours.dart';

/// page for home
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomePageController controller = HomePageController();
    return Scaffold(
      backgroundColor: Colours.baseColour,
      body: ValueListenableBuilder<bool>(
        valueListenable: globalSocketController.isDeviceOnlineNotifier,
        builder: (context, isDeviceOnline, child) =>
            ValueListenableBuilder<int>(
                valueListenable: globalSocketController.deviceStateNotifier,
                builder: (context, deviceState, child) {
                  String deviceStateText = 'unknown';
                  String lockDeviceText = 'Lock';
                  String disableDeviceText = 'Disable';
                  bool lockDeviceEnabled = true;
                  bool disableDeviceEnabled = true;
                  if (isDeviceOnline) {
                    switch (deviceState) {
                      case 0:
                        deviceStateText = 'unlocked';
                        break;
                      case 1:
                        deviceStateText = 'locked';
                        lockDeviceText = 'Unlock';
                        break;
                      case 2:
                        deviceStateText = 'disabled';
                        disableDeviceText = 'Enable';
                        lockDeviceEnabled = false;
                        break;
                      default:
                    }
                  } else {
                    deviceStateText = 'offline';
                    lockDeviceEnabled = false;
                    disableDeviceEnabled = false;
                  }

                  return Row(
                    children: [
                      SizedBox(
                        width: 550,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50, left: 50),
                          child: ListView(
                            children: [
                              Text(
                                'Your device is',
                                style: TextStyles.titleLight,
                              ),
                              Text(
                                deviceStateText,
                                style: TextStyles.title,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    ButtonWidget(
                                      label: lockDeviceText,
                                      onTap: () => controller.updateDeviceState(
                                          deviceState == 0 ? 1 : 0),
                                      color: lockDeviceEnabled
                                          ? Colours.baseColourVarDark
                                          : Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: ButtonWidget(
                                        label: disableDeviceText,
                                        onTap: () =>
                                            controller.updateDeviceState(
                                          deviceState == 2 ? 1 : 2,
                                        ),
                                        color: disableDeviceEnabled
                                            ? Colours.errColour
                                            : Colors.grey,
                                        textStyle: TextStyles.textMed.copyWith(
                                          color: Colours.darkTextColour,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SecurityProfiles(controller: controller),

                              // history
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'Device History',
                                  style: TextStyles.textMedBold,
                                ),
                              ),
                              Text(
                                'View past attempts at unlocking the device',
                                style: TextStyles.textTiny,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // picture
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 50, bottom: 50, right: 15),
                          child: Image.asset('assets/muscle.png'),
                        ),
                      ),
                    ],
                  );
                }),
      ),
    );
  }
}

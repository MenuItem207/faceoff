import 'package:client/env.dart';
import 'package:client/src/config.dart/rounded.dart';
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
        builder: (context, isDeviceOnline, child) => ValueListenableBuilder<
                int>(
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
                      child: ValueListenableBuilder<List>(
                        valueListenable:
                            globalSocketController.loginAttemptsNotifier,
                        builder: (context, loginAttempts, child) {
                          return CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
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
                                            onTap: () =>
                                                controller.updateDeviceState(
                                                    deviceState == 0 ? 1 : 0),
                                            color: lockDeviceEnabled
                                                ? Colours.baseColourVarDark
                                                : Colors.grey,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: ButtonWidget(
                                              label: disableDeviceText,
                                              onTap: () =>
                                                  controller.updateDeviceState(
                                                deviceState == 2 ? 1 : 2,
                                              ),
                                              color: disableDeviceEnabled
                                                  ? Colours.errColour
                                                  : Colors.grey,
                                              textStyle:
                                                  TextStyles.textMed.copyWith(
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
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: loginAttempts.length,
                                  (context, index) {
                                    Map loginAttempt = loginAttempts[index];
                                    bool isSuccess =
                                        loginAttempt['success_state'] == 1;
                                    // add 8 hours since parse doesn't convert hours properly
                                    DateTime datetime = DateTime.parse(
                                            loginAttempt['timestamp'])
                                        .add(
                                      const Duration(hours: 8),
                                    );
                                    String datetimeString =
                                        '${addPadding(datetime.day)} / ${addPadding(datetime.month)} / ${datetime.year} at ${addPadding(datetime.hour)}:${addPadding(datetime.minute)}';

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  datetimeString,
                                                  style: TextStyles.textSmall,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  child: Text(
                                                    isSuccess
                                                        ? 'Success'
                                                        : 'Failure',
                                                    style: TextStyles.textTiny
                                                        .copyWith(
                                                      color: isSuccess
                                                          ? null
                                                          : Colours.errColour,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 80,
                                            width: 80,
                                            child: Card(
                                              shape: Rounded.cardBorder,
                                              elevation: 10,
                                              color: Colours.lightColourVar1,
                                              child: ClipRRect(
                                                borderRadius: Rounded.circular,
                                                child: Image.network(
                                                  '$authServerAddress/image/${loginAttempt['img_url'] ?? ''}',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // picture
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 50, bottom: 50, right: 15),
                      child: Image.asset('assets/muscle.png'),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  /// adds padding to datetime
  String addPadding(int value) {
    if (value > 9) return value.toString();
    return '0$value';
  }
}

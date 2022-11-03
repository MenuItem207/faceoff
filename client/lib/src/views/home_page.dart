import 'package:client/src/config.dart/text_styles.dart';
import 'package:client/src/views/widgets/button_widget.dart';
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
        builder: (context, isDeviceOnline, child) => ValueListenableBuilder<
                int>(
            valueListenable: globalSocketController.deviceStateNotifier,
            builder: (context, deviceState, child) {
              String deviceStateText = 'unknown';
              if (isDeviceOnline) {
                switch (deviceState) {
                  case 0:
                    deviceStateText = 'unlocked';
                    break;
                  case 1:
                    deviceStateText = 'locked';
                    break;
                  case 2:
                    deviceStateText = 'disabled';
                    break;
                  default:
                }
              } else {
                deviceStateText = 'offline';
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
                                  label: 'Lock',
                                  onTap: () {},
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: ButtonWidget(
                                    label: 'Disable',
                                    onTap: () {},
                                    color: Colours.errColour,
                                    textStyle: TextStyles.textMed.copyWith(
                                      color: Colours.darkTextColour,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // profiles
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'Security Profiles',
                              style: TextStyles.textMedBold,
                            ),
                          ),
                          Text(
                            'Select a profile to edit or delete it',
                            style: TextStyles.textMed,
                          ),
                          SizedBox(
                            height: 140,
                            child: ValueListenableBuilder<List>(
                                valueListenable: globalSocketController
                                    .securityProfilesNotifier,
                                builder: (context, securityProfiles, child) {
                                  int maxIndex = securityProfiles.length;
                                  return ListView.builder(
                                    itemCount: maxIndex + 1,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      bool isMaxIndex = index == maxIndex;
                                      if (isMaxIndex) {
                                        return SizedBox(
                                          width: 150,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 80,
                                                width: 80,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  color: Colours.lightColour,
                                                  child: Icon(
                                                    Icons.add_rounded,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'New Profile',
                                                style: TextStyles.textSmallBold,
                                              )
                                            ],
                                          ),
                                        );
                                      }

                                      Map profile = securityProfiles[index];
                                      return SizedBox(
                                        width: 80,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 80,
                                              child: Image.network(
                                                profile['image_url'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Text(
                                              profile['name'],
                                              style: TextStyles.textSmallBold,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }),
                          ),

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
                            style: TextStyles.textMed,
                          ),
                        ],
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
}

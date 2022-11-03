import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:client/env.dart';
import 'package:client/src/views/widgets/button_widget.dart';
import 'package:client/src/views/widgets/super_styled_text_field.dart';
import 'package:client/src/controllers/globals/global_socket_controller.dart';
import 'package:client/src/controllers/pages/home_page_controller.dart';
import 'package:client/src/config.dart/rounded.dart';
import 'package:client/src/config.dart/text_styles.dart';
import 'package:client/src/config.dart/colours.dart';

/// widget for security profiles management
class SecurityProfiles extends StatefulWidget {
  final HomePageController controller;
  const SecurityProfiles({
    super.key,
    required this.controller,
  });

  @override
  State<SecurityProfiles> createState() => _SecurityProfilesState();
}

class _SecurityProfilesState extends State<SecurityProfiles> {
  Map? selectedSecurityProfile;
  bool showEditing = false;
  String? userInputName;
  MediaInfo? userInputImage;

  /// notifier for security profile input field's error
  ValueNotifier<String> userInputFieldErrorNotifier = ValueNotifier('');

  void showEditingMode([Map? selectedProfile]) {
    userInputName = null;
    userInputImage = null;
    userInputFieldErrorNotifier.value = '';

    if (selectedProfile == null) {
      // new profile
      selectedSecurityProfile = null;
    } else {
      // edit profile
      selectedSecurityProfile = selectedProfile;
    }

    showEditing = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String editingModeHintText = 'Name';
    String secondEditButtonLabel = 'Cancel';
    bool isEditExistingProfile = selectedSecurityProfile != null;
    if (isEditExistingProfile) {
      editingModeHintText = selectedSecurityProfile!['name'];
      secondEditButtonLabel = 'Delete';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'Security Profiles',
            style: TextStyles.textMedBold,
          ),
        ),

        // description
        Text(
          'Select a profile to edit or delete it',
          style: TextStyles.textTiny,
        ),

        showEditing
            ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: SuperStyledTextField(
                        hintText: editingModeHintText,
                        onChanged: (newText) => userInputName = newText,
                        errorMessage: userInputFieldErrorNotifier,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: GestureDetector(
                        onTap: () async {
                          userInputImage = await ImagePickerWeb.getImageInfo;
                          setState(() {});
                        },
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Card(
                            shape: Rounded.cardBorder,
                            elevation: 10,
                            color: Colours.lightColourVar1,
                            child: userInputImage == null
                                ? isEditExistingProfile
                                    ? ClipRRect(
                                        borderRadius: Rounded.circular,
                                        child: Image.network(
                                          '$authServerAddress/image/${selectedSecurityProfile!['img_url'] ?? ''}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colours.lightColour,
                                        size: 40,
                                      )
                                : ClipRRect(
                                    borderRadius: Rounded.circular,
                                    child: Image.memory(
                                      userInputImage!.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),

        showEditing
            ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    ButtonWidget(
                      label: 'Save',
                      onTap: () {
                        if (isEditExistingProfile) {
                          // TODO: check if valid
                          if (userInputName == '') {
                            userInputFieldErrorNotifier.value =
                                'Invalid User Name';
                            return;
                          }

                          widget.controller.onSaveChanges(
                            selectedSecurityProfile: selectedSecurityProfile,
                            userInputName: userInputName,
                            userInputImage: userInputImage,
                          );
                        } else {
                          if (userInputName == null || userInputName == '') {
                            userInputFieldErrorNotifier.value =
                                'Invalid User Name';
                            return;
                          }

                          if (userInputImage == null) {
                            userInputFieldErrorNotifier.value =
                                'Select an image first';
                            return;
                          }

                          widget.controller.onSaveChanges(
                            selectedSecurityProfile: selectedSecurityProfile,
                            userInputName: userInputName,
                            userInputImage: userInputImage,
                          );
                          // TODO: upload image
                          showEditing = false;
                          setState(() {});
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: ButtonWidget(
                        label: secondEditButtonLabel,
                        onTap: () {
                          if (isEditExistingProfile) {
                            // delete
                            globalSocketController.sendDeleteUserProfileEvent(
                                selectedSecurityProfile!['id']);
                            showEditing = false;
                            setState(() {});
                          } else {
                            // close editing mode
                            showEditing = false;
                            setState(() {});
                          }
                        },
                        color: Colours.errColour,
                        textStyle: TextStyles.textMed.copyWith(
                          color: Colours.darkTextColour,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),

        // user profiles
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: SizedBox(
            height: 140,
            child: ValueListenableBuilder<List>(
              valueListenable: globalSocketController.securityProfilesNotifier,
              builder: (context, securityProfiles, child) {
                int maxIndex = securityProfiles.length;
                return ListView.builder(
                  itemCount: maxIndex + 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    bool isMaxIndex = index == maxIndex;
                    if (isMaxIndex) {
                      return GestureDetector(
                        onTap: showEditingMode,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Card(
                                elevation: 10,
                                margin: EdgeInsets.zero,
                                shape: Rounded.cardBorder,
                                color: Colours.lightColour,
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 40,
                                  color: Colours.baseColour,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                              ),
                              child: Text(
                                'New Profile',
                                style: TextStyles.textTinyBold,
                              ),
                            )
                          ],
                        ),
                      );
                    }

                    Map profile = securityProfiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () => showEditingMode(profile),
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: Card(
                                  shape: Rounded.cardBorder,
                                  elevation: 10,
                                  color: Colours.lightColourVar1,
                                  child: ClipRRect(
                                    borderRadius: Rounded.circular,
                                    child: Image.network(
                                      '$authServerAddress/image/${profile['img_url'] ?? ''}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  profile['name'],
                                  style: TextStyles.textTinyBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

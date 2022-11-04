import 'dart:convert';

import 'package:client/src/controllers/globals/global_socket_controller.dart';
import 'package:client/src/controllers/helpers/api_helper.dart';
import 'package:image_picker_web/image_picker_web.dart';

/// handles logic related to home page
class HomePageController {
  /// save latest changes
  void onSaveChanges({
    Map? selectedSecurityProfile,
    String? userInputName,
    MediaInfo? userInputImage,
  }) async {
    if (selectedSecurityProfile == null) {
      // create
      assert(userInputName != null && userInputImage != null);
      // upload image
      final response = await APIHelpers.uploadImage(userInputImage!);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String imgURL = data['filename'];
        globalSocketController.sendCreateUserProfileEvent(
          userInputName!,
          imgURL,
        );
      }
    } else {
      // update
      String name = userInputName ?? selectedSecurityProfile['name'];
      String imageURL = selectedSecurityProfile['img_url'];
      if (userInputImage != null) {
        final response = await APIHelpers.uploadImage(userInputImage);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          imageURL = data['filename'];
        }
      }
      globalSocketController.sendUpdateUserProfileEvent(
        name,
        imageURL,
        selectedSecurityProfile['id'],
      );
    }
  }

  /// deletes profile
  void onDeletePressed(int id) {
    globalSocketController.sendDeleteUserProfileEvent(id);
  }

  /// updates the device state
  void updateDeviceState(int newState) {
    globalSocketController.sendUpdateDeviceStateEvent(newState);
  }
}

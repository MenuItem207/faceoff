import 'dart:convert';

import 'package:client/src/controllers/helpers/naviagtion_helper.dart';
import 'package:client/src/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:client/src/controllers/globals/global_socket_controller.dart';
import 'package:client/src/controllers/helpers/api_helper.dart';

/// stores logic for [LoginPage]
class LoginPageController {
  /// notifier for [isLogin]
  ValueNotifier<bool> isLoginNotifier = ValueNotifier(true);

  /// whether or not current mode is login or register
  bool get isLogin => isLoginNotifier.value;

  /// updates the value of [isLogin], if [newIsLogin] is not provided then toggles the value
  void updateIsLogin(bool newIsLogin) {
    isLoginNotifier.value = newIsLogin;
  }

  /// current user input for name
  String nameInput = '';

  /// notifier for name input field's error
  ValueNotifier<String> nameInputFieldErrorNotifier = ValueNotifier('');

  /// returns true if name is valid
  bool verifyNameInputField() {
    return nameInput != '';
  }

  /// called on name input field text changed
  bool onNameInputFieldChanged(String newText) {
    nameInput = newText;
    bool isValid = verifyNameInputField();
    if (!isValid) {
      nameInputFieldErrorNotifier.value = 'Enter a valid name';
    } else {
      nameInputFieldErrorNotifier.value = '';
    }

    return isValid;
  }

  /// current user input for email
  String emailInput = '';

  /// notifier for email input field's error
  ValueNotifier<String> emailInputFieldErrorNotifier = ValueNotifier('');

  /// returns true if email is valid
  bool verifyEmailInputField() {
    return emailInput != '';
  }

  /// called on email input field text changed
  bool onEmailInputFieldChanged(String newText) {
    emailInput = newText;
    bool isValid = verifyEmailInputField();
    if (!isValid) {
      emailInputFieldErrorNotifier.value = 'Enter a valid email';
    } else {
      emailInputFieldErrorNotifier.value = '';
    }

    return isValid;
  }

  /// current user input for password
  String passwordInput = '';

  /// notifier for password input field's error
  ValueNotifier<String> passwordInputFieldErrorNotifier = ValueNotifier('');

  /// returns true if password is valid
  bool verifyPasswordInputField() {
    return passwordInput != '' && passwordInput.length > 6;
  }

  /// called on password input field text changed
  bool onPasswordInputFieldChanged(String newText) {
    passwordInput = newText;
    bool isValid = verifyPasswordInputField();
    if (!isValid) {
      passwordInputFieldErrorNotifier.value = 'Enter a valid password';
    } else {
      passwordInputFieldErrorNotifier.value = '';
    }

    return isValid;
  }

  /// current user input for join code
  String joinCodeInput = '';

  /// notifier for join code input field's error
  ValueNotifier<String> joinCodeInputFieldErrorNotifier = ValueNotifier('');

  /// returns true if join code is valid
  bool verifyJoinCodeInputField() {
    return joinCodeInput != '' && joinCodeInput.length == 5;
  }

  /// called on join code input field text changed
  bool onJoinCodeInputFieldChanged(String newText) {
    joinCodeInput = newText;
    bool isValid = verifyJoinCodeInputField();
    if (!isValid) {
      joinCodeInputFieldErrorNotifier.value =
          'Join Code must be 5 characters in length i.e JSKLE';
    } else {
      joinCodeInputFieldErrorNotifier.value = '';
    }

    return isValid;
  }

  /// on submit button pressed
  void onSubmit(BuildContext context) async {
    try {
      if (isLogin) {
        // verify
        if (onEmailInputFieldChanged(emailInput) &&
            onPasswordInputFieldChanged(passwordInput)) {
          final response = await APIHelpers.login(emailInput, passwordInput);
          if (response.statusCode == 200) {
            // logged in
            int deviceID = jsonDecode(response.body)['device_id'];
            globalSocketController.connectSocket(
                deviceID,
                () =>
                    NavigationHelper.navigateToPage(context, const HomePage()));
            print('logged in');
          } else {
            switch (response.statusCode) {
              case 400:
                passwordInputFieldErrorNotifier.value = 'Invalid password';
                break;
              case 401:
                emailInputFieldErrorNotifier.value = 'Unknown email';
                break;
              default:
            }
          }
        }
      } else {
        // verify
        if (onNameInputFieldChanged(nameInput) &&
            onEmailInputFieldChanged(emailInput) &&
            onPasswordInputFieldChanged(passwordInput) &&
            onJoinCodeInputFieldChanged(joinCodeInput)) {
          final response = await APIHelpers.register(
            nameInput,
            emailInput,
            passwordInput,
            joinCodeInput,
          );
          if (response.statusCode == 200) {
            // logged in
            int deviceID = int.parse(jsonDecode(response.body)['device_id']);
            globalSocketController.connectSocket(
                deviceID,
                () =>
                    NavigationHelper.navigateToPage(context, const HomePage()));
            print('logged in');
          } else {
            switch (response.statusCode) {
              case 400:
                emailInputFieldErrorNotifier.value = 'Email already in use';
                break;
              case 401:
                joinCodeInputFieldErrorNotifier.value = 'Invalid Code';
                break;
              default:
            }
          }
        }
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }
}

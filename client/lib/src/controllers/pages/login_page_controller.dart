import 'package:flutter/material.dart';

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
  void onNameInputFieldChanged(String newText) {
    nameInput = newText;
    bool isValid = verifyNameInputField();
    if (!isValid) {
      nameInputFieldErrorNotifier.value = 'Enter a valid name';
    } else {
      nameInputFieldErrorNotifier.value = '';
    }
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
  void onEmailInputFieldChanged(String newText) {
    emailInput = newText;
    bool isValid = verifyEmailInputField();
    if (!isValid) {
      emailInputFieldErrorNotifier.value = 'Enter a valid email';
    } else {
      emailInputFieldErrorNotifier.value = '';
    }
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
  void onPasswordInputFieldChanged(String newText) {
    passwordInput = newText;
    bool isValid = verifyPasswordInputField();
    if (!isValid) {
      passwordInputFieldErrorNotifier.value = 'Enter a valid password';
    } else {
      passwordInputFieldErrorNotifier.value = '';
    }
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
  void onJoinCodeInputFieldChanged(String newText) {
    joinCodeInput = newText;
    bool isValid = verifyJoinCodeInputField();
    if (!isValid) {
      joinCodeInputFieldErrorNotifier.value =
          'Join Code must be 5 characters in length i.e JSKLE';
    } else {
      joinCodeInputFieldErrorNotifier.value = '';
    }
  }
}

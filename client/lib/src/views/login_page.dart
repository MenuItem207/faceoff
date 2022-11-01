import 'package:client/src/views/widgets/button_widget.dart';
import 'package:client/src/views/widgets/super_styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:client/src/config.dart/colours.dart';
import 'package:client/src/config.dart/text_styles.dart';
import 'package:client/src/controllers/pages/login_page_controller.dart';

/// page for logging in
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginPageController controller = LoginPageController();
    return Scaffold(
      backgroundColor: Colours.baseColour,
      body: Row(
        children: [
          // login stuff
          SizedBox(
            width: 550,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: ValueListenableBuilder<bool>(
                  valueListenable: controller.isLoginNotifier,
                  builder: (context, isLogin, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Face Off',
                          style: TextStyles.title,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: [
                              ButtonWidget(
                                label: 'Login',
                                onTap: () => controller.updateIsLogin(true),
                                showCard: isLogin,
                                textStyle: TextStyles.textSmall,
                                color: Colours.baseColourVarDark,
                              ),
                              ButtonWidget(
                                label: 'Register',
                                onTap: () => controller.updateIsLogin(false),
                                showCard: !isLogin,
                                textStyle: TextStyles.textSmall,
                                color: Colours.baseColourVarDark,
                              ),
                            ],
                          ),
                        ),
                        isLogin
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: SuperStyledTextField(
                                  hintText: 'Name',
                                  onChanged: controller.onNameInputFieldChanged,
                                  errorMessage:
                                      controller.nameInputFieldErrorNotifier,
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SuperStyledTextField(
                            hintText: 'Email',
                            onChanged: controller.onEmailInputFieldChanged,
                            errorMessage:
                                controller.emailInputFieldErrorNotifier,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SuperStyledTextField(
                            hintText: 'Password',
                            onChanged: controller.onPasswordInputFieldChanged,
                            errorMessage:
                                controller.passwordInputFieldErrorNotifier,
                          ),
                        ),
                        isLogin
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: SuperStyledTextField(
                                  hintText: 'Join Code',
                                  onChanged:
                                      controller.onJoinCodeInputFieldChanged,
                                  errorMessage: controller
                                      .joinCodeInputFieldErrorNotifier,
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: ButtonWidget(
                            label: 'Submit',
                            onTap: () {},
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),

          // picture
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 50, bottom: 50, right: 15),
            child: Image.asset('assets/muscle.png'),
          )),
        ],
      ),
    );
  }
}

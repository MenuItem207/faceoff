import 'package:client/src/config.dart/text_styles.dart';
import 'package:client/src/views/widgets/text_field.dart';
import 'package:flutter/material.dart';

/// built on top of styled text field, this widget shows error messages and adds a button at the end of the text field
class SuperStyledTextField extends StatelessWidget {
  /// hint text to show when no input has been provided
  final String hintText;

  /// on user changed text input
  final Function onChanged;

  /// set to null to hide error message
  final ValueNotifier<String?>? errorMessage;

  /// text editing controller
  final TextEditingController? controller;

  /// set to null to hide
  final Widget? icon;

  /// padding for text field
  final EdgeInsets? padding;

  const SuperStyledTextField({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.errorMessage,
    this.controller,
    this.icon,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledTextField(
              hintText: hintText,
              onChanged: onChanged,
              controller: controller,
              padding: padding,
            ),
            ValueListenableBuilder<String?>(
              valueListenable: errorMessage ?? ValueNotifier(null),
              builder: (context, errorMessage, child) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: errorMessage == null ? 0 : 15,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      errorMessage ?? '',
                      style: TextStyles.textError,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        icon == null
            ? const SizedBox()
            : Align(
                alignment: Alignment.centerRight,
                child: icon!,
              ),
      ],
    );
  }
}

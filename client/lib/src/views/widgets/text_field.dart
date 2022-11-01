import 'package:client/src/config.dart/colours.dart';
import 'package:client/src/config.dart/text_styles.dart';
import 'package:flutter/material.dart';

/// text field
class StyledTextField extends StatelessWidget {
  final String hintText;
  final Function onChanged;
  final TextEditingController? controller;
  final EdgeInsets? padding;
  const StyledTextField({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colours.lightColour,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 20,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            hintStyle: TextStyles.textMedDark,
          ),
          style: TextStyles.textMedDark,
          onChanged: (value) => onChanged(value),
        ),
      ),
    );
  }
}

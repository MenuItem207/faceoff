import 'package:flutter/material.dart';
import 'package:client/src/config.dart/colours.dart';
import 'package:client/src/config.dart/text_styles.dart';

/// wraps a widget with padding and colour
class ButtonWidget extends StatelessWidget {
  final String label;
  final Function onTap;
  final bool showCard;
  final Color? color;
  final TextStyle? textStyle;
  const ButtonWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.showCard = true,
    this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        showCard ? color ?? Colours.lightColourVar1 : Colors.transparent;
    final double elevation = showCard ? 10 : 0;

    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: elevation,
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 15,
            left: 20,
            right: 20,
          ),
          child: Text(
            label,
            style: textStyle ?? TextStyles.textMed,
          ),
        ),
      ),
    );
  }
}

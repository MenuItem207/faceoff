import 'package:flutter/material.dart';

class Rounded {
  /// circular border radius
  static BorderRadius circular = BorderRadius.circular(
    15,
  );

  /// border for card
  static ShapeBorder cardBorder = RoundedRectangleBorder(
    borderRadius: circular,
  );
}

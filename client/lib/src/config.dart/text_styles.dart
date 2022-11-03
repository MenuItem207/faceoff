import 'package:client/src/config.dart/colours.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// text styles for the app
class TextStyles {
  /// text style for title
  static final TextStyle title = GoogleFonts.montserrat(
    fontSize: 50,
    fontWeight: FontWeight.w800,
    color: Colours.lightTextColour,
  );

  /// text style for light title
  static final TextStyle titleLight = GoogleFonts.montserrat(
    fontSize: 50,
    fontWeight: FontWeight.w400,
    color: Colours.lightTextColour,
  );

  /// text style for medium text
  static final TextStyle textMed = GoogleFonts.montserrat(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: Colours.lightTextColour,
  );

  /// text style for bold medium text
  static final TextStyle textMedBold = GoogleFonts.montserrat(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    color: Colours.lightTextColour,
  );

  /// text style for medium text
  static final TextStyle textMedDark = GoogleFonts.montserrat(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: Colours.darkTextColour,
  );

  /// text style for smaller text
  static final TextStyle textSmall = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: Colours.lightTextColour,
  );

  /// text style for bold smaller text
  static final TextStyle textSmallBold = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colours.lightTextColour,
  );

  /// text style for error text
  static final TextStyle textError = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: Colours.lightTextColour,
  );
}

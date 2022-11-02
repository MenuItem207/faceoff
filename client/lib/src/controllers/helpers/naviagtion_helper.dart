import 'package:flutter/material.dart';

/// contains helpers that simplifies navigation
class NavigationHelper {
  /// navigates to a new page
  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  /// navigates back to previous page
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}

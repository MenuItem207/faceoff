import 'package:dargon2_flutter/dargon2_flutter.dart';

class EncryptionHelper {
  /// encrpyts the given [String]
  static Future<String> encrypt(String text) async {
    return (await argon2.hashPasswordString(text,
            salt: Salt([24, 128, 36, 10, 904, 2901, 1, 1049, 44])))
        .base64String;
  }
}

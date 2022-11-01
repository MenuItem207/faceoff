import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:client/env.dart';
import 'package:client/src/controllers/helpers/encryption_helper.dart';

/// contains api requests
class APIHelpers {
  /// authenticates the user
  static Future login(String email, String password) async {
    return await http.post(
      Uri.parse('$authServerAddress/login'),
      headers: headers,
      body: jsonEncode(
        <String, String>{
          'email': email,
          'password': await EncryptionHelper.encrypt(password),
        },
      ),
    );
  }

  /// authenticates the user
  static Future register(
      String name, String email, String password, String joinCode) async {
    return await http.post(
      Uri.parse('$authServerAddress/register'),
      headers: headers,
      body: jsonEncode(
        <String, String>{
          'name': name,
          'email': email,
          'password': await EncryptionHelper.encrypt(password),
          'join_code': joinCode,
        },
      ),
    );
  }

  /// headers for http requests
  static final Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };
}

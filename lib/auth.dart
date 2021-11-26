import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'page/login.dart';
import 'page/home.dart';

dynamic homeState = const LoginPage();

Future<bool> login(String username, String password) async {
  const storage = FlutterSecureStorage();
  String? oldCookie = await storage.read(key: 'cookie');

  if (oldCookie != null) {
    return true;
  }

  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  final Uri url = Uri.https('api.vrchat.cloud', "/api/1/auth/user");
  final http.Response response = await http
      .get(url, headers: <String, String>{'authorization': basicAuth});
  String? cookie = response.headers[HttpHeaders.setCookieHeader];
  if (cookie == null) {
    return false;
  }

  await storage.write(key: 'cookie', value: cookie);
  return true;
}

Future<void> auth() async {
  const storage = FlutterSecureStorage();
  String? cookies = await storage.read(key: 'cookie');

  // 期限の切れたcookieを破棄
  // storage.delete(key: 'cookie');

  if (cookies == null) {
    homeState = const LoginPage();
  } else {
    homeState = const HomePage();
  }
}

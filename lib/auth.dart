import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:http/http.dart' as http;

import 'page/login.dart';
import 'page/online_friends.dart';

final cj = CookieJar();
dynamic homeState = const LoginPage();

Future<bool> login(String username, String password) async {
  List<Cookie> oldCookies =
      await cj.loadForRequest(Uri.parse("https:///api.vrchat.cloud/"));
  if (oldCookies.isNotEmpty) {
    return true;
  }

  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  final Uri url = Uri.https('api.vrchat.cloud', "/api/1/auth/user");
  final http.Response response = await http
      .get(url, headers: <String, String>{'authorization': basicAuth});
  String? cookie = response.headers[HttpHeaders.setCookieHeader];
  // ??= もしnullなら代入
  cookie ??= '';
  if (cookie.isEmpty) {
    return false;
  }
  List<Cookie> cookies = [
    // Stringクラスから、_Cookieクラスに変換する
    Cookie.fromSetCookieValue(cookie),
  ];
  //Save cookies
  await cj.saveFromResponse(Uri.parse("https:///api.vrchat.cloud/"), cookies);
  return true;
}

String getCookieString(List<Cookie> cookies) {
  return cookies.map((cookie) => "${cookie.name}=${cookie.value}").join('; ');
}

void auth() async {
  List<Cookie> cookies =
      await cj.loadForRequest(Uri.parse("https:///api.vrchat.cloud/"));

  // 期限の切れたcookieを破棄
  // cookies.removeWhere((cookie) {
  //   if (cookie.expires != null) {
  //     return cookie.expires!.isBefore(DateTime.now());
  //   }
  //   return false;
  // });

  if (cookies.isNotEmpty) {
    homeState = const OnlineFriendsPage();
  } else {
    homeState = const LoginPage();
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'user.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';

// cookieはストレージに保存しないとアプリ終了時に消えそう
final cj = CookieJar();
dynamic homeState = const LoginPage();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    auth();
    return MaterialApp(
      title: 'VRChat Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homeState,
    );
  }
}

// オンラインフレンド一覧
class OnlineFriendsPage extends StatelessWidget {
  const OnlineFriendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: fetchOnlineFriendsFromVRChat(),
        builder: (context, snapshot) {
          // APIからデータを取得できている場合
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  String thumbnailUrl;
                  if (snapshot.data![index].profilePicOverride.isNotEmpty) {
                    thumbnailUrl = snapshot.data![index].profilePicOverride;
                  } else {
                    thumbnailUrl =
                        snapshot.data![index].currentAvatarThumbnailImageUrl;
                  }

                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                thumbnailUrl,
                                width: 120,
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return const UserShowPage();
                                  }));
                                },
                                child: Text(
                                  snapshot.data![index].displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider()
                      ]);
                });
            // } else if(snapshot.data!.isEmpty) {
            //   return const Text('オンラインのフレンドはいません。');
            // APIリクエストが失敗した時
          } else if (snapshot.hasError) {
            return const Text('データの取得に失敗しました。お問い合わせフォームからご連絡ください。');
          }

          return const CircularProgressIndicator();
        },
        // child: Text('オンラインフレンド一覧'),
      ),
    );
  }

  Future<List<User>> fetchOnlineFriendsFromVRChat() async {
    List<Cookie> cookies =
        await cj.loadForRequest(Uri.parse("https:///api.vrchat.cloud/"));
    if (cookies.isEmpty) {
      // ログイン画面にリダイレクト
    }
    final String cookie = _getCookieString(cookies);

    final Uri url = Uri.https('api.vrchat.cloud', '/api/1/auth/user/friends', {
      'offline': 'false',
      'apiKey': '',
    });
    final http.Response response =
        await http.get(url, headers: <String, String>{'Cookie': cookie});

    if (response.statusCode != 200) {
      // エラーが発生しました
      List<User> userList = [];
      return userList;
    }

    final responseMap = json.decode(response.body).cast<Map<String, dynamic>>();
    List<User> userList = createUserList(responseMap);
    return userList;
  }

  List<User> createUserList(List data) {
    List<User> list = [];
    for (int i = 0; i < data.length; i++) {
      User user = User(
        displayName: data[i]["displayName"],
        currentAvatarThumbnailImageUrl: data[i]
            ["currentAvatarThumbnailImageUrl"],
        profilePicOverride: data[i]["profilePicOverride"],
      );
      list.add(user);
    }
    return list;
  }
}

// ユーザー詳細
class UserShowPage extends StatelessWidget {
  const UserShowPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            // "pop"で前の画面に戻る
            Navigator.of(context).pop();
          },
          child: const Text('ユーザー詳細（クリックで戻る）'),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Log in'),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextField(
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      labelText: 'Username/Email:',
                                    ),
                                  ),
                                  const SizedBox(height: 24.0),
                                  TextField(
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      labelText: 'password',
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                height: 54.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.blue),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () {
                                    // submit!
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const OnlineFriendsPage();
                                    }));
                                    if (Text(usernameController.text).data ==
                                            '' ||
                                        Text(passwordController.text).data ==
                                            '') {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            content: Text('フォームに値を入力してください'),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('login'),
                                ),
                              ),
                            ],
                          ))));
            },
          ),
        ));
  }
}

void login(String username, String password) async {
  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  final Uri url = Uri.https('api.vrchat.cloud', "/api/1/auth/user");
  final http.Response response = await http
      .get(url, headers: <String, String>{'authorization': basicAuth});
  String? cookie = response.headers[HttpHeaders.setCookieHeader];
  // ??= もしnullなら代入
  cookie ??= '';
  List<Cookie> cookies = [
    // Stringクラスから、_Cookieクラスに変換する
    Cookie.fromSetCookieValue(cookie),
  ];
  //Save cookies
  await cj.saveFromResponse(Uri.parse("https:///api.vrchat.cloud/"), cookies);
}

String _getCookieString(List<Cookie> cookies) {
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

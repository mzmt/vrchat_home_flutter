import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import 'user_profile.dart';

class OnlineFriendsPage extends StatefulWidget {
  const OnlineFriendsPage({Key? key}) : super(key: key);

  @override
  _OnlineFriendsPageState createState() => _OnlineFriendsPageState();
}

class _OnlineFriendsPageState extends State<OnlineFriendsPage> {
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
                                    return const UserProfilePage();
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.sync_rounded),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<List<User>> fetchOnlineFriendsFromVRChat() async {
    const storage = FlutterSecureStorage();
    String? cookies = await storage.read(key: 'cookie');
    if (cookies == null) {
      // ログイン画面にリダイレクト
      return <User>[];
    }

    final Uri url = Uri.https('api.vrchat.cloud', '/api/1/auth/user/friends',
        {'offline': 'false', 'apiKey': dotenv.env['API_KEY']});
    final http.Response response =
        await http.get(url, headers: <String, String>{'Cookie': cookies});

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

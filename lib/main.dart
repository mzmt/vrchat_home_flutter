import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VRChat Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OnlineFriendPage(),
    );
  }
}

// オンラインユーザー一覧
class OnlineFriendPage extends StatelessWidget {
  const OnlineFriendPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<User>>(
          future: fetchUsersFromGitHub(),
          builder: (context, snapshot) {
            // APIからデータを取得できている場合
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(snapshot.data![index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Divider()
                        ]);
                  });
              // APIリクエストが失敗した時
            } else if (snapshot.hasError) {
              return const Text('データの取得に失敗しました。お問い合わせフォームからご連絡ください。');
            }

            return const CircularProgressIndicator();
          },
        ),
        // child: Text('オンラインフレンド一覧'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // pushした際に、フレンド詳細画面に遷移
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return const UserShowPage();
            }),
          );
        },
      ),
    );
  }

  Future<List<User>> fetchUsersFromGitHub() async {
    final url = Uri.https('api.github.com', '/users');
    final response = await http.get(url);

    print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<User> userList = createUserList(responseJson);
    return userList;
  }

  List<User> createUserList(List data) {
    List<User> list = [];
    for (int i = 0; i < data.length; i++) {
      String title = data[i]["login"];
      int id = data[i]["id"];
      User user = User(name: title, id: id);
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

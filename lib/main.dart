import 'package:flutter/material.dart';

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

class OnlineFriendPage extends StatelessWidget {
  const OnlineFriendPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('オンラインフレンド一覧'),
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
}

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

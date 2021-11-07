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
      home: OnlineFriendPage(),
    );
  }
}

class OnlineFriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('オンラインフレンド一覧'),
    ));
  }
}

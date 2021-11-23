import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../auth.dart';
import 'online_friends.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _hidePassword = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                                      obscureText: _hidePassword,
                                      controller: passwordController,
                                      decoration: InputDecoration(
                                          labelText: 'password',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(_hidePassword
                                                ? FontAwesomeIcons.solidEye
                                                : FontAwesomeIcons
                                                    .solidEyeSlash),
                                            onPressed: () {
                                              setState(() {
                                                _hidePassword = !_hidePassword;
                                              });
                                            },
                                          ))),
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
                                      return;
                                    }
                                    login(Text(usernameController.text).data!,
                                            Text(passwordController.text).data!)
                                        .then((result) {
                                      if (result) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const OnlineFriendsPage();
                                        }));
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return const AlertDialog(
                                              content: Text('ログインに失敗しました'),
                                            );
                                          },
                                        );
                                      }
                                    });
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

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        const ListTile(
          title: Align(
              alignment: Alignment.centerLeft, child: Text('version 1.0.0')),
        ),
        ListTile(
          title: TextButton(
              onPressed: () {
                // logout and go to login page
              },
              child: const Align(
                  alignment: Alignment.centerLeft, child: Text('Logout'))),
        ),
      ]).toList(),
    ));
  }
}

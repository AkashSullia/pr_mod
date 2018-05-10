import 'package:flutter/material.dart';
import 'package:pr_mod/pages/home.dart';
import 'package:pr_mod/pages/repo_page.dart';
import 'package:pr_mod/pages/make_post.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'PR Mod',
      routes: <String, WidgetBuilder>{
        '/Home': (BuildContext context) => new HomePage(),
        '/reporter_account': (BuildContext context) => new RepoPage(),
        '/make_post': (BuildContext context) => new MakePost(),
      },
      theme: new ThemeData(brightness: Brightness.dark),
      home: new HomePage(),
    );
  }
}

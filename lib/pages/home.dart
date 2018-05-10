import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pr_mod/pages/repo_page.dart';

class HomePage extends StatefulWidget {
  final String title = 'PR Mod';
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication authentication =
        await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);
    print("User Name: ${user.displayName}");
    return user;
  }

  void _signOut() {
    googleSignIn.signOut();
    print("User Signed out");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
              color: Colors.green,
              onPressed: () {
                _signIn().then((FirebaseUser user) {
                  print(user);
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) =>
                            new RepoPage(username: user.displayName)),
                  );
                }).catchError((e) => print(e));
              },
              child: new Text("Sign in"),
            ),
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
              color: Colors.red,
              onPressed: () => _signOut(),
              child: new Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}

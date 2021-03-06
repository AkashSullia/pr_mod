import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:validate/validate.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
final reference = FirebaseDatabase.instance.reference();

class MakePost extends StatefulWidget {
  //MakePost({Key key, this.username}) : super(key: key);
  @override
  State createState() => new _MakePostState();
}

class _MakePostState extends State<MakePost> {
  //_MakePostState({this.username});
  //final String username;
  final TextEditingController _textControllerTitle =
      new TextEditingController();
  final TextEditingController _textControllerBody = new TextEditingController();
  bool _isComposing = false;
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future<GoogleSignInAccount> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      print('user is null, attempting silent sign in.');
      user = await googleSignIn.signInSilently();
    }
    if (user == null) {
      print('user is null, attempting sign in.');
      await googleSignIn.signIn();
      analytics.logLogin();
    }
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
          await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
    return user;
  }

  Future<Null> _handlePost(String title, String body, File imageFile) async {
    _textControllerTitle.clear();
    _textControllerBody.clear();
    setState(() {
      _isComposing = false;
    });
    GoogleSignInAccount user = await _ensureLoggedIn();
    if (imageFile != null) {
      int random = new Random().nextInt(10000);
      StorageReference ref =
          FirebaseStorage.instance.ref().child('$title' + '_$random.jpg');
      StorageUploadTask uploadTask = ref.putFile(imageFile);
      Uri downloadUrl = (await uploadTask.future).downloadUrl;
      _postIt(title, body, downloadUrl.toString(), user);
    } else {
      _postIt(title, body, null, user);
    }
  }

  void _postIt(
      String title, String body, String imageUrl, GoogleSignInAccount user) {
    if (imageUrl != null) {
      reference
          .child("users/")
          .child(user.displayName)
          .child("posts/")
          .push()
          .set({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
      });
    } else {
      reference
          .child("users/")
          .child(user.displayName)
          .child("posts/")
          .push()
          .set({
        'title': title,
        'body': body,
      });
    }
    analytics.logEvent(name: 'added_post');
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Create post'),
      ),
      body: new Form(
        key: _formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new TextFormField(
              controller: _textControllerTitle,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Title cannot be empty.';
                }
              },
              maxLines: 1,
              decoration: new InputDecoration(
                hintText: "Title",
              ),
            ),
            new ListTile(
              title: new TextFormField(
                controller: _textControllerBody,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Title cannot be empty.';
                  }
                },
                maxLines: 5,
                decoration: new InputDecoration(
                  hintText: "Body",
                ),
              ),
            ),
            new Row(
              children: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.camera),
                  onPressed: getImage,
                ),
                new Center(
                  child: _image == null
                      ? new Text('No image picked.')
                      : new Image.file(_image,
                          fit: BoxFit.contain, height: 120.0, width: 120.0),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _isComposing
            ? () {
                if ()
                  _handlePost(_textControllerTitle.text,
                      _textControllerBody.text, _image);
              }
            : null,
        child: new Icon(Icons.done),
      ),
    );
  }
}

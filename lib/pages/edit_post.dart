import 'dart:io';
import 'dart:math';
import 'dart:async';
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
//final DataSnapshot snapshot;
final reference = FirebaseDatabase.instance.reference();

class EditPost extends StatefulWidget {
  final DataSnapshot snapshot;
  EditPost({Key key, this.snapshot}) : super(key: key);
  @override
  State createState() => new _EditPostState(snapshot: snapshot);
}

class _EditPostState extends State<EditPost> {
  _EditPostState({this.snapshot});
  final DataSnapshot snapshot;
  TextEditingController _textControllerTitle;
  TextEditingController _textControllerBody;

  bool _isComposing = false;
  Image _image; //= new File.fromUri(new Uri.dataFromString(imageUrl));

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = new Image.file(image);
    });
  }

//  StreamSubscription _subName;
//
//  @override
//  void initState() {
//    if (_textControllerTitle != null) {
//      _textControllerTitle.clear();
//    }
//    if (_textControllerBody != null) {
//      _textControllerBody.clear();
//    }
//    getNameStream(snapshot.key, _fn)
//        .then((StreamSubscription s) => _subName = s);
//  }
//
//  @override
//  void dispose() {
//    if (_subName != null) {
//      _subName.cancel();
//    }
//    super.dispose();
//  }
//
//  void _fn(String title, String body, String imageUrl) {
//    _textControllerTitle.value =
//        _textControllerTitle.value.copyWith(text: title);
//    _textControllerBody.value = _textControllerTitle.value.copyWith(text: body);
//  }

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

//  Future<StreamSubscription<Event>> getNameStream(String key,
//      void onData(String title, String body, String imageUrl)) async {
//    GoogleSignInAccount user = await _ensureLoggedIn();
//    StreamSubscription<Event> subscription = FirebaseDatabase.instance
//        .reference()
//        .child('users/')
//        .child(user.displayName)
//        .child('posts/')
//        .child(snapshot.key)
//        .onValue
//        .listen((Event event) {
//      String title = event.snapshot.value['title'] as String;
//      String body = event.snapshot.value['body'] as String;
//      String imageUrl = event.snapshot.value['imageUrl'] as String;
//      onData(title, body, imageUrl);
//    });
//    return subscription;
//  }

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
          .child('users/')
          .child(user.displayName)
          .child('posts/')
          .child(snapshot.key)
          .update({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'timeStamp': new DateTime.now().toString(),
      });
    } else {
      reference
          .child('users/')
          .child(user.displayName)
          .child('posts/')
          .child(snapshot.key)
          .update({
        'title': title,
        'body': body,
        'timeStamp': new DateTime.now().toString(),
      });
    }
    analytics.logEvent(name: 'edited_post');
  }

  @override
  Widget build(BuildContext context) {
    Map map = snapshot.value;
    String title = map['title'] as String;
    String body = map['body'] as String;
    String imageUrl = map['imageUrl'] as String;
    _image = (imageUrl == null ? imageUrl : new Image.network(imageUrl));
    _textControllerTitle = new TextEditingController();
    _textControllerBody = new TextEditingController();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Edit post'),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            title: new TextField(
              controller: _textControllerTitle,
              maxLines: 1,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              decoration: new InputDecoration(
                hintText: "Title",
              ),
            ),
          ),
          new ListTile(
            title: new TextField(
              controller: _textControllerBody,
              maxLines: 5,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              decoration: new InputDecoration(
                hintText: "Body",
              ),
            ),
          ),
          new Padding(padding: new EdgeInsets.all(10.0)),
          new Row(
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.camera),
                onPressed: getImage,
              ),
              new Container(
                constraints:
                    new BoxConstraints.expand(height: 300.0, width: 300.0),
                height: 300.0,
                width: 300.0,
                child: _image == null ? new Text('No image picked.') : _image,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _isComposing
            ? () {
                var emptySnacks;
                if (_textControllerTitle.text.isEmpty ||
                    _textControllerBody.text.isEmpty) {
                  emptySnacks = new SnackBar(
                    content: new Text('Title or Body cannot be empty.'),
                  );
                } else {
                  _handlePost(_textControllerTitle.text,
                      _textControllerBody.text, _image);
                }
                Scaffold.of(this.context).showSnackBar(emptySnacks);
              }
            : null,
        child: new Icon(Icons.done),
      ),
    );
  }
}

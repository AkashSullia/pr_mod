import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:pr_mod/pages/edit_post.dart';

class AdminPage extends StatefulWidget {
  final String username;
  AdminPage({Key key, this.username}) : super(key: key);
  @override
  State createState() => new _AdminPageState(username: username);
}

class _AdminPageState extends State<AdminPage> {
  _AdminPageState({this.username});
  final String username;
  var userset = ['Akash Sullia', 'Firebase User'];
  @override
  Widget build(BuildContext context) {
    final reference = FirebaseDatabase.instance
        .reference()
        .child('users/');

     Widget body = new Container(
      padding: new EdgeInsets.all(32.0),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Text('$username logged in successfully'),
            new Padding(padding: const EdgeInsets.all(15.0)),
            new Text('No posts to show!')
          ],
        ),
      ),
    );
    if (reference != null) {
      body = new FirebaseAnimatedList(
          query: reference,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map map = snapshot.value;
            String title = map['title'] as String;
            String body = map['body'] as String;
            String imageUrl = map['imageUrl'] as String;
            return new Column(
              children: <Widget>[
                new Card(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new ListTile(
                          leading: imageUrl != null
                              ? new Image.network(imageUrl,
                                  height: 80.0,
                                  width: 80.0,
                                  fit: BoxFit.contain)
                              : new Text('No Image.'),
                          title: new Text(title),
                          subtitle: new Text(body)),
                      new ButtonTheme.bar(
                        child: new ButtonBar(
                          children: <Widget>[
                            new FlatButton(
                              child: new Text('Edit'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new EditPost(snapshot: snapshot)));
                              },
                            ),
                            new FlatButton(
                                child: new Text('Delete'),
                                onPressed: () {
                                  reference.child(snapshot.key).remove();
                                })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('PR Mod'),
      ),
      body: body,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/make_post');
        },
        child: new Icon(Icons.add),
      ),
    );
  }
}

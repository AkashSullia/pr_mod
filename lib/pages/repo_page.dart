import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:pr_mod/pages/edit_post.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:sqljocky/utils.dart';
import 'dart:async';


class RepoPage extends StatefulWidget {
  final String username;
  RepoPage({Key key, this.username}) : super(key: key);
  @override
  State createState() => new _RepoPageState(username: username);
}

class _RepoPageState extends State<RepoPage> {
  _RepoPageState({this.username});
  final String username;

  Future _testDatabase() async{
    print('In Database function');
   ConnectionPool pool = new ConnectionPool(
       host: '192.168.42.153',
       port:3306,
       user:'homestead',
       password:'secret',
       db:'PRmodule',
       max:5);
   print('connection successful: ${pool.toString()}');
   var results = await pool.query('SELECT * FROM USERS');
   print('results working');
   results.forEach((row){
    print('$row');
   });
   //var query = await query
  }
  @override
  Widget build(BuildContext context) {
    final reference = FirebaseDatabase.instance
        .reference()
        .child('users/')
        .child('$username')
        .child('posts/');

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
                                }),
                            new FlatButton(
                              child: new Text('Test Database'),
                              onPressed: (){
                                _testDatabase();
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

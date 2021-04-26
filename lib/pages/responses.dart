import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_recovery/pages/add_post.dart';
import 'package:disaster_recovery/pages/homepage.dart';
import 'package:disaster_recovery/pages/myPosts.dart';
import 'package:disaster_recovery/pages/myRequests.dart';
import 'package:disaster_recovery/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'string_extension.dart';

class Responses extends StatefulWidget {
  @override
  _ResponsesState createState() => _ResponsesState();
}

class _ResponsesState extends State<Responses> {
  final storage = new FlutterSecureStorage();

  String uid, email;

  void initState() {
    super.initState();
    try {
      storage.read(key: 'email').then((value) {
        setState(() {
          email = value;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    String name;
    return Scaffold(
      appBar: AppBar(
          title: Text('RESPONSES',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: 'sans-serif-light',
                  color: Colors.white))),
      drawer: new Drawer(
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("users_details")
                .where('email', isEqualTo: email)
                .get()
                .then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((result) async => {
                    name = await result.data()['name'],
                  });
            }),
            builder: (context, snapshot) {
              if (name == null) {
                return Center(child: new CircularProgressIndicator());
              }
              return ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: new Text(
                      name.capitalize(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    accountEmail: new Text(
                      email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new ExactAssetImage('assets/tsunami.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => ProfilePage()));
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Colors.blue
                                : Colors.white,
                        child: Text(
                          name.toString()[0].capitalize(),
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                      leading: Icon(Icons.home),
                      title: new Text("Home"),
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => HomePage()));
                      }),
                  ListTile(
                      leading: Icon(Icons.wallpaper),
                      title: new Text("My Posts"),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => MyPosts()));
                      }),
                  ListTile(
                      leading: Icon(Icons.live_help),
                      title: new Text("My Requests"),
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => MyRequests()));
                      }),
                  Divider(),
                  ListTile(
                      leading: Icon(Icons.add_a_photo),
                      title: new Text("Add Post"),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => AddPost()));
                      }),
                  ListTile(
                      leading: Icon(Icons.read_more),
                      title: new Text("Responses"),
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => Responses()));
                      }),
                  Divider(),
                  ListTile(
                      leading: Icon(Icons.power_settings_new),
                      title: new Text("Signout"),
                      onTap: () {
                        logoutProcess(context);
                      }),
                ],
              );
            }),
      ),
      body: Posts(),
    );
  }
}

Widget Posts() {
  return StreamBuilder(
      stream: firestoreInstance.collection(email + " response").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: new CircularProgressIndicator());
        } else {
          return GridView.count(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              children: List.generate(snapshot.data.docs.length, (i) {
                return Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(child: 
                      Card(
                        borderOnForeground: true,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/res.png')),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          margin: EdgeInsets.all(10),
                          child: InkWell(
                            splashColor: Colors.grey,
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/responseDetails', arguments: {
                                'details': snapshot.data.docs[i],
                                'id': snapshot.data.docs[i].id
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    margin: EdgeInsets.only(top: 10),
                                    child: RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(children: <TextSpan>[
                                        TextSpan(
                                            text: snapshot.data.docs[i]
                                                .data()['time'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black38,
                                              fontFamily: 'sans-serif-light',
                                            )),
                                      ]),
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      margin: EdgeInsets.only(left: 10),
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text: snapshot.data.docs[i]
                                                  .data()['name']
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                      )),
                                ),
                                SizedBox(height: 7),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    margin: EdgeInsets.only(left: 10),
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(children: <TextSpan>[
                                        TextSpan(
                                            text: snapshot.data.docs[i]
                                                .data()['email']
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey)),
                                      ]),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      )
                      )
                    ],
                  ),
                );
              }));
        }
      });
}

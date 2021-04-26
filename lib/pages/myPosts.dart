import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_recovery/pages/add_post.dart';
import 'package:disaster_recovery/pages/homepage.dart';
import 'package:disaster_recovery/pages/myRequests.dart';
import 'package:disaster_recovery/pages/profile.dart';
import 'package:disaster_recovery/pages/responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'string_extension.dart';

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
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
          title: Text('MY POSTS',
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

void swipeDelete(context, id) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Are you sure you want to delete "),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                firestoreInstance.collection('posts').doc(id).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Widget Posts() {
  return StreamBuilder(
      stream: firestoreInstance
          .collection('posts')
          .where('email', isEqualTo: email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: new CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              padding: EdgeInsets.all(5.0),
              itemBuilder: (context, i) {
                return snapshot.data.docs[i].data()['requested'] == false
                    ? Dismissible(
                        key: Key(snapshot.data.docs[i].id),
                        background: slideLeftBackground(),
                        confirmDismiss: (direction) {
                          if (snapshot.data.docs[i].data()['requested'] ==
                              false) {
                            swipeDelete(context, snapshot.data.docs[i].id);
                          }
                        },
                        child: Card(
                          borderOnForeground: true,
                          margin: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: InkWell(
                            splashColor: Colors.grey,
                            onTap: () {
                              foodDetails(context, snapshot.data.docs[i]);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        CircleAvatar(
                                            child: Text(snapshot.data.docs[i]
                                                .data()['name'][0]
                                                .toString()
                                                .capitalize())),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              child: Text(
                                                snapshot.data.docs[i]
                                                    .data()['name']
                                                    .toString()
                                                    .capitalize(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              child: Text(
                                                snapshot.data.docs[i]
                                                    .data()['time']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                        snapshot.data.docs[i]
                                                    .data()['requested'] ==
                                                true
                                            ? Text("")
                                            : Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  tooltip: 'Edit',
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () async {
                                                    updateFoodDetails(
                                                        context,
                                                        snapshot.data.docs[i],
                                                        snapshot
                                                            .data.docs[i].id);
                                                  },
                                                ))
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Card(
                        borderOnForeground: true,
                        margin: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: () {
                            foodDetails(context, snapshot.data.docs[i]);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      CircleAvatar(
                                          child: Text(snapshot.data.docs[i]
                                              .data()['name'][0]
                                              .toString()
                                              .capitalize())),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              snapshot.data.docs[i]
                                                  .data()['name']
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              snapshot.data.docs[i]
                                                  .data()['time']
                                                  .toString(),
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      snapshot.data.docs[i]
                                                  .data()['requested'] ==
                                              true
                                          ? Text("")
                                          : Align(
                                              alignment: Alignment.topRight,
                                              child: IconButton(
                                                tooltip: 'Edit',
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () async {
                                                  updateFoodDetails(
                                                      context,
                                                      snapshot.data.docs[i],
                                                      snapshot.data.docs[i].id);
                                                },
                                              ))
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      );
              });
        }
      });
}

Widget slideLeftBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            " Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}

void foodDetails(context, food) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Food Details'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          actions: <Widget>[
            FlatButton(
              child: const Text('Back'),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textColor: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Divider(),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: food.data()['post'].length,
                        itemBuilder: (context, i) {
                          return Column(
                            children: <Widget>[
                              SizedBox(height: 7),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left: 10),
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Category : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: food
                                              .data()['post'][i]['category']
                                              .toString()
                                              .capitalize(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ]),
                                  )),
                              SizedBox(height: 7),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left: 10),
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Item : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: food
                                              .data()['post'][i]
                                                  ['categoryItems']
                                              .toString()
                                              .capitalize(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ]),
                                  )),
                              SizedBox(height: 7),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left: 10),
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Quantity : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: food
                                              .data()['post'][i]['quantity']
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ]),
                                  )),
                              SizedBox(height: 7),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  margin: EdgeInsets.only(left: 10),
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Unit : ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: food
                                              .data()['post'][i]['unit']
                                              .toString()
                                              .capitalize(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ]),
                                  )),
                              Divider(),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

Future<bool> dialogTrigger(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Message', style: TextStyle(fontSize: 15.0)),
            content: Text("Update Successfully!"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("ok"),
                  textColor: Colors.blue)
            ]);
      });
}

void updateFoodDetails(context, food, id) async {
  DocumentSnapshot foodDetails = food;
  final postDetails = [];
  final postDetailsCheck = [];
  final DateFormat formatter = DateFormat().add_yMEd().add_jm();

  postDetails.add(foodDetails.data()['post']);
  postDetailsCheck.add(foodDetails.data()['post']);

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Food Details'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                  child: new Text("Update"),
                  onPressed: () {
                    bool zero = false;
                    bool notSame = false;
                    bool singleindex = false;
                    bool singleindexZero = false;
                    if (postDetails[0].length > 1) {
                      for (int i = 0; i < postDetails[0].length; i++) {
                        if (postDetails[0][i]['quantity'] == 0) {
                          zero = true;
                        }
                        if (postDetails[0][i]['quantity'] !=
                            postDetailsCheck[0][i]['quantity']) {
                          notSame = true;
                        }
                      }
                    } else {
                      if (postDetails[0][0]['quantity'] ==
                          postDetailsCheck[0][0]['quantity']) {
                        singleindex = true;
                      }
                      if (postDetails[0][0]['quantity'] == 0) {
                        singleindexZero = true;
                      }
                    }
                    if (postDetails[0].length > 1) {
                      if (zero == false) {
                        if (notSame == true) {
                          firestoreInstance
                              .collection("posts")
                              .doc(id)
                              .update({'post': FieldValue.delete()})
                              .then((res) => {
                                    firestoreInstance
                                        .collection('posts')
                                        .doc(id)
                                        .update({
                                      'time': formatter.format(DateTime.now()),
                                      'post':
                                          FieldValue.arrayUnion(postDetails[0])
                                    }),
                                    Navigator.of(context).pop(),
                                    dialogTrigger(context)
                                  })
                              .catchError((e) => {print(e)});
                        } else {
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                              msg: "No updates!",
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          notSame = false;
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Quantity should not be less than 1!",
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        notSame = false;
                      }
                    } else {
                      if (singleindex == false) {
                        if (singleindexZero == false) {
                          firestoreInstance
                              .collection("posts")
                              .doc(id)
                              .update({'post': FieldValue.delete()})
                              .then((res) => {
                                    firestoreInstance
                                        .collection('posts')
                                        .doc(id)
                                        .update({
                                      'time': formatter.format(DateTime.now()),
                                      'post':
                                          FieldValue.arrayUnion(postDetails[0])
                                    }),
                                    Navigator.of(context).pop(),
                                    dialogTrigger(context)
                                  })
                              .catchError((e) => {print(e)});
                        }else{
                          Fluttertoast.showToast(
                            msg: "Quantity should not be less than 1!",
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        singleindex = false; 
                        }
                      } else {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg: "No updates!",
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        singleindex = false;
                      }
                    }
                  }),
            ],
            content: Container(
                child: SingleChildScrollView(
              child: Form(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Divider(),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: foodDetails.data()['post'].length,
                            itemBuilder: (context, i) {
                              return Column(
                                children: <Widget>[
                                  SizedBox(height: 7),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      margin: EdgeInsets.only(left: 10),
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text: "Category : ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: foodDetails
                                                  .data()['post'][i]['category']
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ]),
                                      )),
                                  SizedBox(height: 7),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      margin: EdgeInsets.only(left: 10),
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text: "Item : ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: foodDetails
                                                  .data()['post'][i]
                                                      ['categoryItems']
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ]),
                                      )),
                                  SizedBox(height: 7),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      margin: EdgeInsets.only(left: 10),
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text: "Unit : ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: foodDetails
                                                  .data()['post'][i]['unit']
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ]),
                                      )),
                                  SizedBox(height: 7),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      margin: EdgeInsets.only(left: 10),
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text: "Quantity : ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: foodDetails
                                                  .data()['post'][i]['quantity']
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ]),
                                      )),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(3, 5, 3, 5),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          labelText: 'Update Quantity',
                                          hintText: "Enter the Quantity ",
                                          prefixIcon:
                                              Icon(Icons.assignment_late),
                                        ),
                                        onChanged: (value) {
                                          postDetails[0][i]['quantity'] =
                                              int.parse(value);
                                        },
                                      )),
                                  Divider(),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            )));
      });
}

Future<bool> deleteDialogTrigger(BuildContext context, deleteData) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('DELETE', style: TextStyle(fontSize: 15.0)),
            content: Text("Are you sure?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                  textColor: Colors.blue),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    firestoreInstance
                        .collection('posts')
                        .doc(deleteData)
                        .delete();
                  },
                  child: Text("Ok"),
                  textColor: Colors.blue)
            ]);
      });
}

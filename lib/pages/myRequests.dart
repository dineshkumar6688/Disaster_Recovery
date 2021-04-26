import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_recovery/pages/add_post.dart';
import 'package:disaster_recovery/pages/homepage.dart';
import 'package:disaster_recovery/pages/myPosts.dart';
import 'package:disaster_recovery/pages/profile.dart';
import 'package:disaster_recovery/pages/responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'string_extension.dart';

class MyRequests extends StatefulWidget {
  @override
  _MyRequestsState createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
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
          title: Text('MY REQUESTS',
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
      stream: firestoreInstance.collection(email + " request").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: new CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              padding: EdgeInsets.all(5.0),
              itemBuilder: (context, i) {
                return Card(
                    child: GestureDetector(
                  onTap: () {
                    foodDetails(context, snapshot.data.docs[i]);
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 240,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      margin:
                                          EdgeInsets.only(top: 40, bottom: 10),
                                    ),
                                    Align(
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8M3x8fGVufDB8fHx8&w=1000&q=80',
                                        height: 200,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20)),
                                  ),
                                  child: new Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      snapshot.data.docs[i].data()['status'] ==
                                              'Pending'
                                          ? Chip(
                                              backgroundColor: Colors.blue,
                                              label: Text(
                                                  'Status: ' +
                                                      snapshot.data.docs[i]
                                                          .data()['status']
                                                          .toString()
                                                          .capitalize(),
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            )
                                          : snapshot.data.docs[i]
                                                      .data()['status'] ==
                                                  'Accepted'
                                              ? Chip(
                                                  backgroundColor: Colors.green,
                                                  label: Text(
                                                      'Status: ' +
                                                          snapshot.data.docs[i]
                                                              .data()['status']
                                                              .toString()
                                                              .capitalize(),
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                )
                                              : Chip(
                                                  backgroundColor: Colors.red,
                                                  label: Text(
                                                      'Status: ' +
                                                          snapshot.data.docs[i]
                                                              .data()['status']
                                                              .toString()
                                                              .capitalize(),
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          child: RichText(
                                            textAlign: TextAlign.end,
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text: snapshot.data.docs[i]
                                                      .data()['time'],
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      fontFamily:
                                                          'sans-serif-light',
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ]),
                                          )),
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: RichText(
                                            textAlign: TextAlign.start,
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text: snapshot.data.docs[i]
                                                              .data()[
                                                                  'servname']
                                                              .toString() !=
                                                          ''
                                                      ? snapshot.data.docs[i]
                                                          .data()['servname']
                                                          .toString()
                                                          .capitalize()
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                          )),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
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
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ]),
                                          )),
                                      SizedBox(height: 7),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          margin: EdgeInsets.only(left: 10),
                                          child: RichText(
                                            textAlign: TextAlign.start,
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text: snapshot.data.docs[i]
                                                      .data()['email']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ]),
                                          )),
                                      SizedBox(height: 7),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          margin: EdgeInsets.only(left: 10),
                                          child: RichText(
                                            textAlign: TextAlign.start,
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text: snapshot.data.docs[i]
                                                      .data()['phoneno']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ]),
                                          )),
                                      SizedBox(height: 7),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          margin: EdgeInsets.only(left: 10),
                                          child: RichText(
                                            textAlign: TextAlign.start,
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text: snapshot.data.docs[i]
                                                      .data()['address']
                                                      .toString()
                                                      .capitalize(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ]),
                                          )),
                                      ButtonBar(children: <Widget>[
                                        FlatButton(
                                          child: const Text('Update'),
                                          onPressed: snapshot.data.docs[i]
                                                          .data()['status'] ==
                                                      'Accepted' ||
                                                  snapshot.data.docs[i]
                                                          .data()['status'] ==
                                                      'Rejected'
                                              ? null
                                              : () async {
                                                  updateRequest(
                                                      context,
                                                      snapshot.data.docs[i],
                                                      snapshot.data.docs[i].id);
                                                },
                                        ),
                                        FlatButton(
                                          child: const Text('Delete'),
                                          onPressed: snapshot.data.docs[i]
                                                          .data()['status'] ==
                                                      'Accepted' ||
                                                  snapshot.data.docs[i]
                                                          .data()['status'] ==
                                                      'Rejected'
                                              ? null
                                              : () async {
                                                  DocumentSnapshot det =
                                                      await firestoreInstance
                                                          .collection(snapshot
                                                                  .data.docs[i]
                                                                  .data()[
                                                                      'email']
                                                                  .toString() +
                                                              ' response')
                                                          .doc(snapshot
                                                              .data.docs[i].id)
                                                          .get();
                                                  deleteRequest(
                                                      context,
                                                      snapshot.data.docs[i].id,
                                                      snapshot.data.docs[i]
                                                          .data()['email']
                                                          .toString());
                                                },
                                        ),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
              });
        }
      });
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
                          return food.data()['post'][i]['quantity'] > 0
                              ? Column(
                                  children: <Widget>[
                                    SizedBox(height: 7),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: food
                                                    .data()['post'][i]
                                                        ['category']
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
                                            MediaQuery.of(context).size.width *
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
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                            MediaQuery.of(context).size.width *
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
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: food
                                                    .data()['post'][i]
                                                        ['quantity']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black)),
                                          ]),
                                        )),
                                    SizedBox(height: 7),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                )
                              : Text('');
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

void updateRequest(context, foodDetails, id) async {
  final postDetails = [];
  for (int i = 0; i < foodDetails.data()['post'].length; i++) {
    postDetails.add({
      'category': foodDetails.data()['post'][i]['category'],
      'categoryItems': foodDetails.data()['post'][i]['categoryItems'],
      'unit': foodDetails.data()['post'][i]['unit'],
      'availQuan': foodDetails.data()['post'][i]['availQuan'],
      'quantity': 0
    });
  }
  String index = id;
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
                  onPressed: () async {
                    bool high = false;
                    bool less = false;
                    bool same = false;
                    var equal = 0;
                    var zero = 0;
                    bool singleindex = false;
                    bool singleindexZero = false;
                    bool singleindexhigher = false;
                    if (postDetails.length > 1) {
                      for (int i = 0; i < postDetails.length; i++) {
                        if (postDetails[i]['quantity'] >
                            foodDetails.data()['post'][i]['availQuan']) {
                          high = true;
                        }
                        if (postDetails[i]['quantity'] ==
                            foodDetails.data()['post'][i]['quantity']) {
                          equal++;
                          if (equal == postDetails.length) {
                            same = true;
                          }
                        }

                        if (postDetails[i]['quantity'] == 0) {
                          zero++;
                          if (zero == postDetails.length) {
                            less = true;
                          }
                        }
                      }
                    } else {
                      if (postDetails[0]['quantity'] ==
                          foodDetails.data()['post'][0]['quantity']) {
                        singleindex = true;
                      }
                      if (postDetails[0]['quantity'] == 0) {
                        singleindexZero = true;
                      }
                      if (postDetails[0]['quantity'] >
                          foodDetails.data()['post'][0]['availQuan']) {
                        singleindexhigher = true;
                      }
                    }
                    if (postDetails.length > 1) {
                      if (high == false) {
                        if (same == false) {
                          if (less == false) {
                            final DateFormat formatter =
                                DateFormat().add_yMEd().add_jm();
                            firestoreInstance
                                .collection(
                                    foodDetails.data()['email'] + " response")
                                .doc(index)
                                .update({'post': FieldValue.delete()}).then(
                                    (value) => {
                                          firestoreInstance
                                              .collection(
                                                  foodDetails.data()['email'] +
                                                      " response")
                                              .doc(index)
                                              .update({
                                            'time': formatter
                                                .format(DateTime.now()),
                                            'post': FieldValue.arrayUnion(
                                                postDetails)
                                          }).then((value) => {
                                                    firestoreInstance
                                                        .collection(
                                                            email + " request")
                                                        .doc(index)
                                                        .update({
                                                      'post':
                                                          FieldValue.delete()
                                                    }).then((value) => {
                                                              firestoreInstance
                                                                  .collection(
                                                                      email +
                                                                          " request")
                                                                  .doc(index)
                                                                  .update({
                                                                    'time': formatter
                                                                        .format(
                                                                            DateTime.now()),
                                                                    'post': FieldValue
                                                                        .arrayUnion(
                                                                            postDetails)
                                                                  })
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Navigator.of(context).pop(),
                                                                            Fluttertoast.showToast(
                                                                                msg: "Request has been updated successfully!",
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.white,
                                                                                textColor: Colors.black,
                                                                                fontSize: 16.0)
                                                                          })
                                                                  .catchError(
                                                                      (e) {
                                                                    print(e);
                                                                  }),
                                                            })
                                                  }),
                                        });
                          } else {
                            Fluttertoast.showToast(
                                msg: "Quantity should not be less than 1!",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 16.0);
                            less = false;
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
                          same = false;
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "Quantity should not be greater than available quantity!",
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        high = false;
                      }
                    } else {
                      if (singleindex == false) {
                        if (singleindexZero == false) {
                          if (singleindexhigher == false) {
                            final DateFormat formatter =
                                DateFormat().add_yMEd().add_jm();
                            firestoreInstance
                                .collection(
                                    foodDetails.data()['email'] + " response")
                                .doc(index)
                                .update({'post': FieldValue.delete()}).then(
                                    (value) => {
                                          firestoreInstance
                                              .collection(
                                                  foodDetails.data()['email'] +
                                                      " response")
                                              .doc(index)
                                              .update({
                                            'time': formatter
                                                .format(DateTime.now()),
                                            'post': FieldValue.arrayUnion(
                                                postDetails)
                                          }).then((value) => {
                                                    firestoreInstance
                                                        .collection(
                                                            email + " request")
                                                        .doc(index)
                                                        .update({
                                                      'post':
                                                          FieldValue.delete()
                                                    }).then((value) => {
                                                              firestoreInstance
                                                                  .collection(
                                                                      email +
                                                                          " request")
                                                                  .doc(index)
                                                                  .update({
                                                                    'time': formatter
                                                                        .format(
                                                                            DateTime.now()),
                                                                    'post': FieldValue
                                                                        .arrayUnion(
                                                                            postDetails)
                                                                  })
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Navigator.of(context).pop(),
                                                                            Fluttertoast.showToast(
                                                                                msg: "Request has been updated successfully!",
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.white,
                                                                                textColor: Colors.black,
                                                                                fontSize: 16.0)
                                                                          })
                                                                  .catchError(
                                                                      (e) {
                                                                    print(e);
                                                                  }),
                                                            })
                                                  }),
                                        });
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Quantity should not be greater than available quantity!",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 16.0);
                            singleindexhigher = false;
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Quantity should not be less than 1!",
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          singleindexZero = false;
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
                              return foodDetails.data()['post'][i]['quantity'] >
                                      0
                                  ? Column(
                                      children: <Widget>[
                                        SizedBox(height: 7),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            margin: EdgeInsets.only(left: 10),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                TextSpan(
                                                    text: "Category : ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text: foodDetails
                                                        .data()['post'][i]
                                                            ['category']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ]),
                                            )),
                                        SizedBox(height: 7),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            margin: EdgeInsets.only(left: 10),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                TextSpan(
                                                    text: "Item : ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text: foodDetails
                                                        .data()['post'][i]
                                                            ['categoryItems']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ]),
                                            )),
                                        SizedBox(height: 7),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            margin: EdgeInsets.only(left: 10),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                TextSpan(
                                                    text: "Unit : ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text: foodDetails
                                                        .data()['post'][i]
                                                            ['unit']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ]),
                                            )),
                                        SizedBox(height: 7),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            margin: EdgeInsets.only(left: 10),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                TextSpan(
                                                    text:
                                                        "Available Quantity : ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text: foodDetails
                                                        .data()['post'][i]
                                                            ['availQuan']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ]),
                                            )),
                                        SizedBox(height: 7),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            margin: EdgeInsets.only(left: 10),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                TextSpan(
                                                    text:
                                                        "Requested Quantity : ",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                TextSpan(
                                                    text: foodDetails
                                                        .data()['post'][i]
                                                            ['quantity']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                              ]),
                                            )),
                                        Container(
                                            margin:
                                                EdgeInsets.fromLTRB(3, 5, 3, 5),
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                labelText: 'Update Quantity',
                                                hintText: "Enter the Quantity ",
                                                prefixIcon:
                                                    Icon(Icons.assignment_late),
                                              ),
                                              onChanged: (value) {
                                                postDetails[i]['quantity'] =
                                                    int.parse(value);
                                              },
                                            )),
                                        Divider(),
                                      ],
                                    )
                                  : Text('');
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            )));
      });
}

Future<bool> deleteRequest(
    BuildContext context, deleteData, deleteEmail) async {
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
                        .collection(email + ' request')
                        .doc(deleteData)
                        .delete();
                    firestoreInstance
                        .collection(deleteEmail + ' response')
                        .doc(deleteData)
                        .delete();
                  },
                  child: Text("Ok"),
                  textColor: Colors.blue)
            ]);
      });
}

import 'package:disaster_recovery/pages/add_post.dart';
import 'package:disaster_recovery/pages/myPosts.dart';
import 'package:disaster_recovery/pages/myRequests.dart';
import 'package:disaster_recovery/pages/profile.dart';
import 'package:disaster_recovery/pages/responses.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../pages/login.page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'string_extension.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

String uid, email, searchString;
final firestoreInstance = FirebaseFirestore.instance;
TextEditingController textEditingController = TextEditingController();

class _HomePageState extends State<HomePage> {
  final storage = new FlutterSecureStorage();

  @override
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
        title: Text(
          "Disaster Recovery",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
                child: TextField(
              onChanged: (value) {
                setState(() {
                  searchString = value;
                });
              },
              controller: textEditingController,
              decoration: InputDecoration(
                  hintText: 'Search items here',
                  hintStyle:
                      TextStyle(fontFamily: 'Antra', color: Colors.blueGrey)),
            )),
          ),
          Expanded(
            child: StreamBuilder(
                stream: (searchString == null || searchString.trim() == '')
                    ? firestoreInstance.collection('posts').snapshots()
                    : firestoreInstance
                        .collection('posts')
                        .where('searchItems', arrayContains: searchString)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: new CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        padding: EdgeInsets.all(5.0),
                        itemBuilder: (context, i) {
                          if (snapshot.data.docs[i]['email'] != email) {
                            return Center(
                                child: GestureDetector(
                                    onTap: () {
                                      foodDetails(
                                          context, snapshot.data.docs[i]);
                                    },
                                    child: Card(
                                        borderOnForeground: true,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        margin: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 20,
                                            bottom: 20),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/BG.png')),
                                                      color: Color(0xFFCFD8DC).withOpacity(0.5),
                                              
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: RichText(
                                                    textAlign: TextAlign.end,
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: snapshot
                                                              .data.docs[i]
                                                              .data()['time'],
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'sans-serif-light',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ]),
                                                  )),
                                              new ListTile(
                                                title: Text(
                                                    snapshot.data.docs[i]
                                                                    .data()[
                                                                'servname'] ==
                                                            ''
                                                        ? snapshot.data.docs[i]
                                                            .data()['servname']
                                                            .toString()
                                                        : snapshot.data.docs[i]
                                                            .data()['servname']
                                                            .toString()
                                                            .capitalize(),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  child: RichText(
                                                    textAlign: TextAlign.start,
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: "Name : ",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      TextSpan(
                                                          text: snapshot
                                                              .data.docs[i]
                                                              .data()['name']
                                                              .toString()
                                                              .capitalize(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ]),
                                                  )),
                                              SizedBox(height: 7),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  child: RichText(
                                                    textAlign: TextAlign.start,
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: "Email : ",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      TextSpan(
                                                          text: snapshot
                                                              .data.docs[i]
                                                              .data()['email']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ]),
                                                  )),
                                              SizedBox(height: 7),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  child: RichText(
                                                    textAlign: TextAlign.start,
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text:
                                                              "Contact Number : ",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      TextSpan(
                                                          text: snapshot
                                                              .data.docs[i]
                                                              .data()['phoneno']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ]),
                                                  )),
                                              SizedBox(height: 7),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  child: RichText(
                                                    textAlign: TextAlign.start,
                                                    text: TextSpan(children: <
                                                        TextSpan>[
                                                      TextSpan(
                                                          text: "Address : ",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      TextSpan(
                                                          text: snapshot
                                                              .data.docs[i]
                                                              .data()['address']
                                                              .toString()
                                                              .capitalize(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ]),
                                                  )),
                                              ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child:
                                                        const Text('Request'),
                                                    onPressed: () async {
                                                      DocumentSnapshot
                                                          updateFood =
                                                          await firestoreInstance
                                                              .collection(
                                                                  'posts')
                                                              .doc(snapshot.data
                                                                  .docs[i].id)
                                                              .get();
                                                      request(
                                                          context,
                                                          updateFood,
                                                          snapshot
                                                              .data.docs[i].id);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ))));
                          } else {
                            return Text('');
                          }
                        });
                  }
                }),
          )
        ]))
      ]),
      drawer: new Drawer(
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("users_details")
                .where('email', isEqualTo: email)
                .get()
                .then((QuerySnapshot snapshot) async {
              snapshot.docs.forEach((result) async => {
                    name = await result.data()['name'],
                  });
            }),
            builder: (context, snapshot) {
              if (email == null) {
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
    );
  }
}

Future<bool> logoutProcess(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Text("Do you want to logout?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("No"),
                  textColor: Colors.blue),
              FlatButton(
                  onPressed: () {
                    logout(context);
                  },
                  child: Text("Yes"),
                  textColor: Colors.blue)
            ]);
      });
}

void logout(context) async {
  final auth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();
  var errorMessage;

  try {
    auth.signOut();
  } catch (e) {
    errorMessage = e;
  }
  if (errorMessage != null) {
    Fluttertoast.showToast(
        msg: errorMessage,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  } else {
    await storage.delete(key: 'email');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }
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

void request(context, foodDetails, donorID) async {
  final postDetails = [];

  for (int i = 0; i < foodDetails.data()['post'].length; i++) {
    postDetails.add({
      'category': foodDetails.data()['post'][i]['category'],
      'categoryItems': foodDetails.data()['post'][i]['categoryItems'],
      'unit': foodDetails.data()['post'][i]['unit'],
      'availQuan': foodDetails.data()['post'][i]['quantity'],
      'quantity': 0
    });
  }
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
                  child: new Text("Request"),
                  onPressed: () async {
                    bool high = false;
                    int zeros = 0;
                    for (int i = 0; i < postDetails.length; i++) {
                      if (postDetails[i]['quantity'] >
                          foodDetails.data()['post'][i]['quantity']) {
                        high = true;
                      }
                      if (postDetails[i]['quantity'] == 0) {
                        zeros++;
                      }
                    }
                    if (zeros == postDetails.length) {
                      Fluttertoast.showToast(
                          msg: "Quantity should not be less than 1!",
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    } else if (high == true) {
                      Fluttertoast.showToast(
                          msg: "Quantity is higher than available!",
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0);
                      high = false;
                    } else {
                      DocumentSnapshot recepientDetails =
                          await firestoreInstance
                              .collection("users_details")
                              .doc(email)
                              .get();
                      String names = recepientDetails.data()['name'];
                      String phone = recepientDetails.data()['phoneno'];
                      String add = recepientDetails.data()['address'];
                      String servName = recepientDetails.data()['servname'];
                      final DateFormat formatter =
                          DateFormat().add_yMEd().add_jm();
                      var uuid = Uuid();
                      var id = uuid.v1();

                      if (names != null &&
                          names != '' &&
                          phone != null &&
                          phone != '' &&
                          add != null &&
                          add != '') {
                        await firestoreInstance
                            .collection('posts')
                            .doc(donorID)
                            .update({'requested': true});

                        firestoreInstance
                            .collection(
                                foodDetails.data()['email'] + " response")
                            .doc(id)
                            .set({
                          'time': formatter.format(DateTime.now()),
                          'servname': servName,
                          'name': names,
                          'phoneno': phone,
                          'address': add,
                          'email': email,
                          'status': 'Pending',
                          'postId': foodDetails.data()['postId'],
                          'post': FieldValue.arrayUnion(postDetails)
                        }).then((value) => {
                                  firestoreInstance
                                      .collection(email + " request")
                                      .doc(id)
                                      .set({
                                        'time':
                                            formatter.format(DateTime.now()),
                                        'servname':
                                            foodDetails.data()['servname'],
                                        'name': foodDetails.data()['name'],
                                        'phoneno':
                                            foodDetails.data()['phoneno'],
                                        'address':
                                            foodDetails.data()['address'],
                                        'email': foodDetails.data()['email'],
                                        'status': 'Pending',
                                        'post':
                                            FieldValue.arrayUnion(postDetails)
                                      })
                                      .then((value) => {
                                            Navigator.of(context).pop(),
                                            Fluttertoast.showToast(
                                                msg: "Request has been sent!",
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.white,
                                                textColor: Colors.black,
                                                fontSize: 16.0)
                                          })
                                      .catchError((e) {
                                        print(e);
                                      }),
                                });
                      } else {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => ProfilePage()));
                        Fluttertoast.showToast(
                            msg: "Profile setup is not completed!",
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
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
                      RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: "Note: ",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "Enter 0 if not necessary",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black)),
                            TextSpan(
                                text: "*",
                                style:
                                    TextStyle(fontSize: 13, color: Colors.red)),
                          ])),
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
                                                        "Available quantity : ",
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
                                                labelText: 'Quantity you need',
                                                hintText:
                                                    "Enter the Quantity you need ",
                                                prefixIcon: Icon(
                                                    Icons.confirmation_number),
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

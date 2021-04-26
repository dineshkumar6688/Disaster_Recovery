import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_recovery/pages/add_post.dart';
import 'package:disaster_recovery/pages/homepage.dart';
import 'package:disaster_recovery/pages/myPosts.dart';
import 'package:disaster_recovery/pages/myRequests.dart';
import 'package:disaster_recovery/pages/profile.dart';
import 'package:disaster_recovery/pages/responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'string_extension.dart';

class ResponseDetails extends StatefulWidget {
  @override
  _ResponseDetailsState createState() => _ResponseDetailsState();
}

Map data = {};

class _ResponseDetailsState extends State<ResponseDetails> {
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
    data = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
          title: Text('RESPONSE DETAILS',
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

  Widget Posts() {
    return StreamBuilder(
        stream: firestoreInstance.collection(email + " response").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: new CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: Column(children: <Widget>[
                data['details'].data()['status'] == 'Pending'
                    ? Chip(
                        backgroundColor: Colors.blue,
                        label: Text(
                            'Status: ' +
                                data['details']
                                    .data()['status']
                                    .toString()
                                    .capitalize(),
                            style: TextStyle(color: Colors.white)),
                      )
                    : data['details'].data()['status'] == 'Accepted'
                        ? Chip(
                            backgroundColor: Colors.green,
                            label: Text(
                                'Status: ' +
                                    data['details']
                                        .data()['status']
                                        .toString()
                                        .capitalize(),
                                style: TextStyle(color: Colors.white)),
                          )
                        : Chip(
                            backgroundColor: Colors.red,
                            label: Text(
                                'Status: ' +
                                    data['details']
                                        .data()['status']
                                        .toString()
                                        .capitalize(),
                                style: TextStyle(color: Colors.white)),
                          ),
                Image.asset('assets/launch_image.jpg'),
                Card(
                    margin: EdgeInsets.only(top: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: <Widget>[
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                decoration: new BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(5),
                                      bottomLeft: const Radius.circular(5)),
                                ),
                                height: 60,
                                width: 10,
                              ),
                            ],
                          ),
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text('Time',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontFamily: 'sans-serif-light',
                                      ))),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                      data['details']
                                          .data()['time']
                                          .toString()
                                          .capitalize(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontFamily: 'sans-serif-light',
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ],
                      ),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      data['details'].data()['servname'] != ''
                          ? Card(
                              margin: EdgeInsets.only(top: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Row(
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          decoration: new BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: new BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(5),
                                                bottomLeft:
                                                    const Radius.circular(5)),
                                          ),
                                          height: 60,
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text('Service Name',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontFamily:
                                                      'sans-serif-light',
                                                ))),
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(
                                                data['details']
                                                    .data()['servname']
                                                    .toString()
                                                    .capitalize(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        'sans-serif-light',
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ],
                                    ),
                                  ],
                                ),
                              ))
                          : Text(''),
                      Card(
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      decoration: new BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(5),
                                            bottomLeft:
                                                const Radius.circular(5)),
                                      ),
                                      height: 60,
                                      width: 10,
                                    ),
                                  ],
                                ),
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('Name',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              fontFamily: 'sans-serif-light',
                                            ))),
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                            data['details']
                                                .data()['name']
                                                .toString()
                                                .capitalize(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontFamily: 'sans-serif-light',
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Card(
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: new BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(5),
                                            bottomLeft:
                                                const Radius.circular(5)),
                                      ),
                                      height: 60,
                                      width: 10,
                                    ),
                                  ],
                                ),
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('Email',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              fontFamily: 'sans-serif-light',
                                            ))),
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                            data['details']
                                                .data()['email']
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontFamily: 'sans-serif-light',
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Card(
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: new BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(5),
                                            bottomLeft:
                                                const Radius.circular(5)),
                                      ),
                                      height: 60,
                                      width: 10,
                                    ),
                                  ],
                                ),
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('Contact',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              fontFamily: 'sans-serif-light',
                                            ))),
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                            data['details'].data()['phoneno'],
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontFamily: 'sans-serif-light',
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Card(
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: new BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(5),
                                            bottomLeft:
                                                const Radius.circular(5)),
                                      ),
                                      height: 60,
                                      width: 10,
                                    ),
                                  ],
                                ),
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('Address',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              fontFamily: 'sans-serif-light',
                                            ))),
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                            data['details']
                                                .data()['address']
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontFamily: 'sans-serif-light',
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            foodDetails(context, data['details']);
                          },
                          child: Card(
                              margin: EdgeInsets.only(top: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Row(
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          decoration: new BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: new BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(5),
                                                bottomLeft:
                                                    const Radius.circular(5)),
                                          ),
                                          height: 60,
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text('Food Details',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontFamily:
                                                      'sans-serif-light',
                                                ))),
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Icon(Icons.arrow_forward)),
                                      ],
                                    ),
                                  ],
                                ),
                              ))),
                      data['details'].data()['status'] == 'Pending'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        acceptResponse(context,
                                            data['details'], data['id']);
                                      },
                                      child: Text('Accept',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontFamily: 'sans-serif-light',
                                          )),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green),
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        rejectResponse(
                                            context,
                                            data['details'],
                                            data['details'].data()['email']);
                                      },
                                      child: Text('Reject',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontFamily: 'sans-serif-light',
                                          )),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.red),
                                      ),
                                    )),
                              ],
                            )
                          : Text('')
                    ],
                  ),
                )
              ]),
            );
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
                            // if (int.parse(food.data()['post'][i]['quantity'] > 0)) {
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
                                            text: food
                                                .data()['post'][i]['category']
                                                .toString(),
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
                                            text: food
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
                                            text: food
                                                .data()['post'][i]['unit']
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ]),
                                    )),
                                Divider(),
                              ],
                            );
                            //  }
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void acceptResponse(context, food, id) async {
    DocumentSnapshot foodDetails = food;
    String index = id;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Accept'),
            content: Text("Are you sure?"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            actions: <Widget>[
              new FlatButton(
                child: new Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                  child: new Text("Yes"),
                  onPressed: () async {
                    DocumentSnapshot recepientDetails = await firestoreInstance
                        .collection(email + ' response')
                        .doc(index)
                        .get();
                    String postId;
                    await firestoreInstance
                        .collection('posts')
                        .where("postId",
                            isEqualTo: recepientDetails.data()['postId'])
                        .get()
                        .then((QuerySnapshot snapshot) async {
                      snapshot.docs.forEach((result) async => {
                            postId = result.data()['postId'],
                          });
                    });
                    DocumentSnapshot details = await firestoreInstance
                        .collection('posts')
                        .doc(postId)
                        .get();

                    final postDetails = [];
                    for (int i = 0; i < details.data()['post'].length; i++) {
                      postDetails.add({
                        'category': details.data()['post'][i]['category'],
                        'categoryItems': details.data()['post'][i]
                            ['categoryItems'],
                        'unit': details.data()['post'][i]['unit'],
                        'quantity': (details.data()['post'][i]['quantity'] -
                                recepientDetails.data()['post'][i]['quantity']),
                      });
                    }
                    await firestoreInstance
                        .collection('posts')
                        .doc(postId)
                        .update({
                          'post': FieldValue.delete(),
                        })
                        .then((value) async => {
                              await firestoreInstance
                                  .collection('posts')
                                  .doc(postId)
                                  .update({
                                'post': FieldValue.arrayUnion(postDetails),
                              })
                            })
                        .then((value) async => {
                              firestoreInstance
                                  .collection(
                                      foodDetails.data()['email'] + " request")
                                  .doc(index)
                                  .update({
                                'status': 'Accepted',
                              }).then((value) => {
                                        firestoreInstance
                                            .collection(email + " response")
                                            .doc(index)
                                            .update({
                                              'status': 'Accepted',
                                            })
                                            .then((value) => {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Responses())),
                                                  Fluttertoast.showToast(
                                                      msg: "Accepted",
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.white,
                                                      textColor: Colors.black,
                                                      fontSize: 16.0),
                                                })
                                            .catchError((e) {
                                              print(e);
                                            }),
                                      })
                            });
                    DocumentSnapshot quantityCheck = await firestoreInstance
                        .collection('posts')
                        .doc(postId)
                        .get();
                    var check = false;
                    for (int i = 0;
                        i < quantityCheck.data()['post'].length;
                        i++) {
                      if (int.parse(
                              quantityCheck.data()['post'][i]['quantity']) >
                          0) {
                        check = true;
                      }
                    }
                    if (check == false) {
                      await firestoreInstance
                          .collection('posts')
                          .doc(postId)
                          .delete();
                    }
                  }),
            ],
          );
        });
  }

  Future<bool> rejectResponse(
      BuildContext context, deleteData, deleteEmail) async {
    final DateFormat formatter = DateFormat().add_yMEd().add_jm();

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Reject', style: TextStyle(fontSize: 15.0)),
              content: Text("Are you sure?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("No"),
                    textColor: Colors.blue),
                FlatButton(
                    onPressed: () async {
                      await firestoreInstance
                          .collection(email + ' response')
                          .doc(deleteData.id)
                          .update({
                        'status': 'Rejected',
                      }).then((value) async => {
                                await firestoreInstance
                                    .collection(deleteEmail + ' request')
                                    .doc(deleteData.id)
                                    .update({
                                  'status': 'Rejected',
                                }).then((value) => {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          Responses())),
                                          Fluttertoast.showToast(
                                              msg: "Rejected",
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.white,
                                              textColor: Colors.black,
                                              fontSize: 16.0),
                                        })
                              });
                    },
                    child: Text("yes"),
                    textColor: Colors.blue)
              ]);
        });
  }
}

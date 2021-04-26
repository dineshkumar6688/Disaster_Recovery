import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_recovery/pages/homepage.dart';
import 'package:disaster_recovery/pages/myPosts.dart';
import 'package:disaster_recovery/pages/myRequests.dart';
import 'package:disaster_recovery/pages/profile.dart';
import 'package:disaster_recovery/pages/responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'string_extension.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  List<String> category = ['Clothes', 'Fruits', 'Foods', 'Biscuits'];
  List<String> clothesItems = ['Shirt', 'Pant', 'Shorts', 'Tracks'];
  List<String> fruitItems = ['Apple', 'Orange', 'Pineapple'];
  List<String> foodItems = ['Lemon', 'Curd', 'Tomato'];
  List<String> biscuitItems = ['Marie Gold', 'Dark Fantasy', 'Oreo'];
  List<String> categoryItems = [];
  String selectedCategory;
  String selectedCategoryItem;
  String _quantity;
  String _unit;

  bool bcategory, bcategoryItem, bquantity, bunit;

  TextEditingController cate = new TextEditingController();
  TextEditingController cateItem = new TextEditingController();
  TextEditingController quantity = new TextEditingController();
  TextEditingController unitController = new TextEditingController();

  final _formCategoryItem = GlobalKey<FormState>();
  final _formquanity = GlobalKey<FormState>();
  final _formUnit = GlobalKey<FormState>();

  var uuid = Uuid();

  final addItemData = [];
  final categoryCheck = [];

  String uid, email;
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
        title: Text('Add a new Post'),
        actions: <Widget>[
          addItemData.length > 0
              ? IconButton(
                  tooltip: 'Undo!',
                  icon: Icon(
                    Icons.undo,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    undoItem();
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.post_add,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                )
        ],
      ),
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
              if (email == null) {
                return Center(child: new CircularProgressIndicator());
              }
              return ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: new Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    accountEmail: new Text(
                      email.capitalize(),
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
      body: Container(
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Category(),
                Items(),
                Quantity(),
                UnitData(),
                ButtonNewItem(),
                AddData()
              ],
            ),
          ],
        ),
      ),
    );
  }

  addPostData() async {
    DocumentSnapshot user =
        await firestoreInstance.collection('users_details').doc(email).get();
    var searchItems = [];

    for (int i = 0; i < addItemData.length; i++) {
      searchItems.add(addItemData[i]['categoryItems']);
      searchItems.add(addItemData[i]['category']);
    }

    var uuid = Uuid();
    var id = uuid.v1();

    String names = user.data()['name'];
    String phone = user.data()['phoneno'];
    String add = user.data()['address'];
    String servName = user.data()['servname'];
    final DateFormat formatter = DateFormat().add_yMEd().add_jm();
    if (names != null &&
        names != '' &&
        phone != null &&
        phone != '' &&
        add != null &&
        add != '') {
      firestoreInstance.collection('posts').doc(id).set({
        'time': formatter.format(DateTime.now()),
        'servname': servName,
        'name': names,
        'phoneno': phone,
        'address': add,
        'email': email,
        'requested': false,
        'postId': id,
        'searchItems': FieldValue.arrayUnion(searchItems),
        'post': FieldValue.arrayUnion(addItemData)
      }).then((value) => {
            Fluttertoast.showToast(
                msg: "Data added successfully!",
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0)
          });
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfilePage()));
      Fluttertoast.showToast(
          msg: "Profile setup is not completed!",
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  Widget AddData() {
    return addItemData.length > 0
        ? Column(
            children: [
              TableData(),
              Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.all(25),
                child: RaisedButton(
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: 10.0),
                  ),
                  onPressed: () async {
                    addPostData();
                  },
                ),
              ),
            ],
          )
        : Comment();
  }

  Widget TableData() => DataTable(
          columns: <DataColumn>[
            DataColumn(
                label: Text("Category"),
                numeric: false,
                tooltip: "Display category"),
            DataColumn(
                label: Text("Items"), numeric: false, tooltip: "display items"),
            DataColumn(
                label: Text("Quantity"),
                numeric: false,
                tooltip: "Display quanity"),
            DataColumn(
                label: Text("Unit"), numeric: false, tooltip: "Display unit")
          ],
          rows: addItemData
              .map((name) => DataRow(cells: [
                    DataCell(Text(name['category'].toString().capitalize())),
                    DataCell(
                        Text(name['categoryItems'].toString().capitalize())),
                    DataCell(Text(name['quantity'].toString())),
                    DataCell(Text(name['unit'].toString().capitalize()))
                  ]))
              .toList());

  Widget Comment() {
    return Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Text("Add some items!"));
  }

  Widget Category() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Form(
            child: Container(
          child: DropdownButtonFormField<String>(
            hint: Text('Category'),
            value: selectedCategory,
            isExpanded: true,
            items: category.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (category) {
              if (category == 'Clothes') {
                categoryItems = clothesItems;
                unitController.text = 'pcs';
                _unit = 'pcs';
                bcategoryItem = true;
                bunit = true;
              } else if (category == 'Fruits') {
                categoryItems = fruitItems;
                unitController.text = 'Kg';
                _unit = 'Kg';
                bcategoryItem = true;
                bunit = true;
              } else if (category == 'Biscuits') {
                categoryItems = biscuitItems;
                unitController.text = 'packet';
                _unit = 'packet';
                bcategoryItem = true;
                bunit = true;
              } else if (category == 'Foods') {
                categoryItems = foodItems;
                unitController.text = 'packet';
                _unit = 'packet';
                bcategoryItem = true;
                bunit = true;
              } else {
                categoryItems = [];
                unitController.text = '';
                _unit = '';
                bcategoryItem = false;
                bunit = false;
              }
              setState(() {
                selectedCategoryItem = null;
                selectedCategory = category;
                bcategory = true;
                bcategoryItem = false;
              });
            },
            validator: (val) =>
                val.isEmpty ? "Category should not be empty" : null,
          ),
        )));
  }

  Widget Items() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Form(
        key: _formCategoryItem,
        child: Container(
          child: DropdownButtonFormField<String>(
            hint: Text('Items'),
            value: selectedCategoryItem,
            isExpanded: true,
            items: categoryItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (categoryItems) {
              setState(() {
                selectedCategoryItem = categoryItems;
                bcategoryItem = true;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget Quantity() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Form(
            key: _formquanity,
            child: TextFormField(
              validator: (val) =>
                  val.isEmpty ? "Quantity should not be empty" : null,
              controller: quantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Quantity",
              ),
              onChanged: (value) {
                _quantity = value;
                if (value != '') {
                  bquantity = true;
                } else {
                  bquantity = false;
                }
              },
            )));
  }

  Widget UnitData() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Form(
          key: _formUnit,
          child: Row(
            children: <Widget>[
              new Expanded(
                child: new TextFormField(
                  controller: unitController,
                  enabled: false,
                  decoration: InputDecoration(
                    filled: false,
                    labelText: 'unit',
                    hintText: "unit",
                  ),
                  onChanged: (value) {
                    _unit = value;
                    bunit = true;
                  },
                ),
                flex: 5,
              ),
            ],
          ),
        ));
  }

  Widget ButtonNewItem() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.blue[300],
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(
              5.0,
              5.0,
            ),
          ),
        ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: FlatButton(
          onPressed: () {
            addItemsData();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'OK',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void undoItem() {
    try {
      if (addItemData.length > 0) {
        setState(() {
          addItemData.removeLast();
        });
        setState(() {
          categoryCheck.removeLast();
        });
      } else {
        Fluttertoast.showToast(
            msg: "No element is present!",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  void addItemsData() {
    if (bcategory == true &&
        bcategoryItem == true &&
        bquantity == true &&
        bunit == true) {
      bool check = categoryCheck.contains(selectedCategoryItem);

      if (check == true) {
        Fluttertoast.showToast(
            msg: "Selected item already present!",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      } else {
        setState(() {
          categoryCheck.add(selectedCategoryItem);
        });

        setState(() {
          addItemData.add({
            "category": selectedCategory.toLowerCase(),
            "categoryItems": selectedCategoryItem.toLowerCase(),
            "quantity": int.parse(_quantity),
            "unit": _unit.toLowerCase()
          });
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Field should not be empty!",
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }
}

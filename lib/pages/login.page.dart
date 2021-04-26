import 'package:disaster_recovery/main.dart';
import 'package:disaster_recovery/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:disaster_recovery/pages/resetpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/newuser.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../pages/loader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

RegExp regEmail = new RegExp(r"[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
    "\\@" +
    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
    "(" +
    "\\." +
    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
    ")+");
RegExp regPassword = new RegExp(
    r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$");

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    getSharedPreferencesData(context);
  }

  String _email, _password;
  final auth = FirebaseAuth.instance;

  bool loader = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final _formEmailKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();

  bool _showPassword = false, _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return loader
        ? Loader()
        : Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.blueGrey, Colors.lightBlueAccent]),
              ),
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(children: <Widget>[
                        VerticalText(),
                        TextLogin(),
                      ]),
                      InputEmail(),
                      PasswordInput(),
                      ButtonLogin(context),
                      ResetPassword(context),
                      FirstTime(context),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget VerticalText() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 10),
      child: RotatedBox(
          quarterTurns: -1,
          child: Text(
            'Sign in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          )),
    );
  }

  Widget TextLogin() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10.0),
      child: Container(
        //color: Colors.green,
        height: 200,
        width: 200,
        child: Column(
          children: <Widget>[
            Container(
              height: 60,
            ),
            Center(
              child: Text(
                'A world of possibility in an app',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget InputEmail() {
    return Padding(
        padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
        child: Form(
          key: _formEmailKey,
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              style: TextStyle(
                color: Colors.white,
              ),
              validator: (val) => val.isEmpty
                  ? "Email should not be empty"
                  : regEmail.hasMatch(val)
                      ? null
                      : "Not a valid Email",
              controller: email,
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Colors.lightBlueAccent,
                labelText: 'E-mail',
                labelStyle: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _email = value.trim();
                });
              },
            ),
          ),
        ));
  }

  Widget PasswordInput() {
    return Padding(
        padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
        child: Form(
          key: _formPasswordKey,
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              style: TextStyle(
                color: Colors.white,
              ),
              validator: (val) =>
                  val.isEmpty ? "Password should not be empty" : null,
              controller: password,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.white70,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: _showPassword ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _password = value.trim();
                });
              },
            ),
          ),
        ));
  }

  Widget ButtonLogin(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue[300],
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                5.0, // horizontal, move right 10
                5.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: FlatButton(
          onPressed: () {
            if (_formEmailKey.currentState.validate() &&
                _formPasswordKey.currentState.validate()) {
              setState(() {
                loader = true;
              });
              loginProcess(_email, _password);
            }
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

  void loginProcess(email, password) async {
    User user = FirebaseAuth.instance.currentUser;
    final storage = new FlutterSecureStorage();

    String errorMessage;
    try {
      user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (!user.emailVerified) {
        errorMessage = "Email not verified";
        setState(() {
          loader = false;
        });
      }
    } catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'user-not-found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'wrong-password';
      } else {
        errorMessage = e;
      }
    }

    if (errorMessage != null) {
      if (errorMessage == 'user-not-found') {
        setState(() {
          loader = false;
        });
        Fluttertoast.showToast(
            msg: 'No user found for that email',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      } else if (errorMessage == 'wrong-password') {
        setState(() {
          loader = false;
        });
        Fluttertoast.showToast(
            msg: 'Wrong password provided for that user',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      } else {
        setState(() {
          loader = false;
        });
        Fluttertoast.showToast(
            msg: errorMessage,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    } else {
      setState(() {
        loader = false;
      });
      await storage.write(key: 'email', value: email);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    }
  }
}

void getSharedPreferencesData(BuildContext context) async {
  final storage = new FlutterSecureStorage();
  bool uid = await storage.containsKey(key: 'email');

  if (uid == true) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }
}

Widget ResetPassword(context) {
  return Padding(
    padding: const EdgeInsets.only(top: 30, left: 30),
    child: Container(
      alignment: Alignment.center,
      //color: Colors.red,
      height: 20,
      child: Row(
        children: <Widget>[
          Text(
            'Oops, have you forgot the passord?',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ResetPage()));
            },
            child: Text(
              '  Reset Password',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget FirstTime(context) {
  return Padding(
    padding: const EdgeInsets.only(top: 30, left: 30),
    child: Container(
      alignment: Alignment.topRight,
      //color: Colors.red,
      height: 20,
      child: Row(
        children: <Widget>[
          Text(
            'Your first time?',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NewUser()));
            },
            child: Text(
              'Sign up',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/login.page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  String _email, _password, _name, _phoneno;
  final auth = FirebaseAuth.instance;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phoneno = TextEditingController();

  final _formNameKey = GlobalKey<FormState>();
  final _formEmailKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();
  final _formPhoneNoKey = GlobalKey<FormState>();

  bool _showPassword = false;

  RegExp regName = new RegExp(r"([a-zA-Z]{3,30}\s*)+");
  RegExp regEmail = new RegExp(r"[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+");
  RegExp regPassword = new RegExp(
      r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Row(
                  children: <Widget>[
                    SignUp(),
                    TextNew(),
                  ],
                ),
                NewName(),
                NewEmail(),
                PasswordInput(),
                Phoneno(),
                ButtonNewUser(),
                UserOld(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget SignUp() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 10),
      child: RotatedBox(
          quarterTurns: -1,
          child: Text(
            'Sign up',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          )),
    );
  }

  Widget TextNew() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10.0),
      child: Container(
        height: 200,
        width: 200,
        child: Column(
          children: <Widget>[
            Container(
              height: 60,
            ),
            Center(
              child: Text(
                'We can start something new',
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

  Widget NewName() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: Form(
        key: _formNameKey,
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: TextFormField(
            style: TextStyle(
              color: Colors.white,
            ),
            validator: (val) => val.isEmpty
                ? "Name should not be empty"
                : regName.hasMatch(val)
                    ? null
                    : "Not a valid Name",
            controller: name,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Colors.lightBlueAccent,
              labelText: 'Name',
              labelStyle: TextStyle(
                color: Colors.white70,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget NewEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
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
      ),
    );
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
            validator: (val) => val.isEmpty
                ? "Password should not be empty"
                : regPassword.hasMatch(val)
                    ? null
                    : "Invalid Password. Example - Password@88",
            controller: password,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Colors.lightBlueAccent,
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
              if (regPassword.hasMatch(value)) {
              } else {}
            },
          ),
        ),
      ),
    );
  }

  Widget Phoneno() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
      child: Form(
        key: _formPhoneNoKey,
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: TextFormField(
            style: TextStyle(
              color: Colors.white,
            ),
            validator: (val) =>
                val.isEmpty ? "Phone no should not be empty" : null,
            controller: phoneno,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Colors.lightBlueAccent,
              labelText: 'Phone no',
              labelStyle: TextStyle(
                color: Colors.white70,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _phoneno = value.trim();
              });
            },
          ),
        ),
      ),
    );
  }

  void signupProcess() async {
    String errorMessage;
    User user = FirebaseAuth.instance.currentUser;
    final firestoreInstance = FirebaseFirestore.instance;

    try {
      user = (await auth.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .user;
    } catch (e) {
      errorMessage = e.message;
    }
    if (errorMessage != null) {
      Fluttertoast.showToast(msg: errorMessage);
    } else {
      try {
        firestoreInstance
            .collection("users_details")
            .doc(_email)
            .set({"name": _name, "phoneno": _phoneno, "email": _email});
        user.sendEmailVerification();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
        Fluttertoast.showToast(
            msg: 'Verification link sent to email successfully',
            backgroundColor: Colors.black);
      } catch (e) {
        Fluttertoast.showToast(msg: e);
      }
    }
  }

  Widget ButtonNewUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        width: MediaQuery.of(context).size.width,
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
            if (_formNameKey.currentState.validate() &&
                _formEmailKey.currentState.validate() &&
                _formPasswordKey.currentState.validate() &&
                _formPhoneNoKey.currentState.validate()) {
              signupProcess();
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

  Widget UserOld() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 30),
      child: Container(
        alignment: Alignment.topRight,
        height: 20,
        child: Row(
          children: <Widget>[
            Text(
              'Have we met before?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text(
                'Sign in',
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
}

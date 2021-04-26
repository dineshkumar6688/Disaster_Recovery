import 'package:disaster_recovery/pages/login.page.dart';
import 'package:disaster_recovery/pages/responseDetails.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MaterialApp(
     routes: <String, WidgetBuilder>{
        '/responseDetails': (BuildContext context) => new ResponseDetails(),
      },
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
       primaryColor: Colors.blue,
    ),
    
    home: new MyApp(),
  ));
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 2,
      navigateAfterSeconds: new LoginPage(),
      title: new Text('     Disaster Recovery\n\nWelcomes you with Care',
      style: new TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0
      ),),
      image: new Image.asset('assets/reqs.jpg'),
      loadingText: Text("Our Mission is to help people every day!!"),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      loaderColor: Colors.red
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:runo_notes/screens/home_screen.dart';
import 'package:runo_notes/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences pref = await SharedPreferences.getInstance();
  var login = pref.getBool('login');
  String id;
  if (login != null && login == true) {
    id = pref.getString('id')!;
  } else {
    id = ' ';
  }
  runApp(MyApp(id));
}

class MyApp extends StatelessWidget {
  MyApp(this.id, {Key? key}) : super(key: key);

  String id;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: id == ' ' ? const LoginPage() : HomeScreen(id: id),
    );
  }
}

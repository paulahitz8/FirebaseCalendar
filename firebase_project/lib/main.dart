import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project/AuthGate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project/screens/calendar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

//const String user = "paulahitz8@gmail.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AuthGate(app: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return MaterialApp(
      home: CalendarScreen(user: user.email!),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String email;
  User(this.email);
}

Future<void> addUser(User user) async {
  final db = FirebaseFirestore.instance;
  db.doc("/users/${user.email}").set(
    {
      "name": "Paula",
    },
  );
}

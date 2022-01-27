import 'package:flutter/material.dart';
import 'package:firebase_project/screens/calendar_screen.dart';
import 'package:firebase_project/screens/todolist_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatelessWidget {
  final String user;

  const MainScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: Column(
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      color: const Color.fromRGBO(214, 125, 0, 1.0),
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        // set up the buttons
                        Widget cancelButton = TextButton(
                          child: const Text("Cancel",
                              style: TextStyle(
                                color: Color.fromRGBO(214, 125, 0, 1.0),
                              )),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );
                        Widget continueButton = TextButton(
                          child: const Text("Sign out",
                              style: TextStyle(
                                color: Color.fromRGBO(214, 125, 0, 1.0),
                              )),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                          },
                        );

                        // set up the AlertDialog
                        AlertDialog alert = AlertDialog(
                          content: const Text(
                            "Would you like to sign out?",
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            cancelButton,
                            continueButton,
                          ],
                        );

                        // show the dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      },
                      iconSize: 28,
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(left: 20),
                      iconSize: 50,
                      icon: Image.asset("assets/honey_bee.png"),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 150),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          fixedSize: const Size(200, 80),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: const Text(
                        "Calendar",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CalendarScreen(
                              user: user,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          fixedSize: const Size(200, 80),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: const Text(
                        "To Dos",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TodoScreen(
                              user: user,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

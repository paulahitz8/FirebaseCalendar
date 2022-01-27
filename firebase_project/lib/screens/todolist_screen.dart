//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project/screens/main_screen.dart';
import 'package:firebase_project/model/todo.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoScreen extends StatelessWidget {
  final String user;

  const TodoScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: user,
      builder: (context, _) => StreamBuilder(
        stream: userTodoSnapshots(user),
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case ConnectionState.active:
              return _TodoScreen(user, snapshot.data!);
            case ConnectionState.none:
              return ErrorWidget("The stream was wrong (connectionState.none)");
            case ConnectionState.done:
              return ErrorWidget("The stream has ended??");
          }
        },
      ),
    );
  }
}

class _TodoScreen extends StatefulWidget {
  final String user;
  final List<Todo> todos;
  const _TodoScreen(this.user, this.todos);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<_TodoScreen> {
  late TextEditingController controller;

  //final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    //_eventController.dispose();
    super.dispose();
  }

  void deleteWithUndo(BuildContext context, Todo todo) {
    deleteTodo(context.read<String>(), todo.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You deleted '${todo.name}'"),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.amber[900],
          onPressed: () {
            undeleteTodo(context.read<String>(), todo);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: Column(
                children: [
                  const SizedBox(height: 15),
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MainScreen(
                                user: widget.user,
                              ),
                            ),
                          );
                        },
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.todos == null)
                              const Text(
                                "Looks like a relaxing day.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            if (widget.todos != null)
                              const Text(
                                "Plans for the day:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            Container(
                              width: 40,
                              height: 40,
                              child: FloatingActionButton(
                                backgroundColor:
                                    const Color.fromRGBO(214, 125, 0, 0.7),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 30),
                                onPressed: () {
                                  // set up the buttons
                                  Widget cancelButton = TextButton(
                                    child: const Text("Cancel",
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(214, 125, 0, 1.0),
                                        )),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                  Widget continueButton = TextButton(
                                    child: const Text("Confirm",
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(214, 125, 0, 1.0),
                                        )),
                                    onPressed: () {
                                      addTodo(
                                          widget.user, controller.text, false);
                                      Navigator.pop(context);
                                      controller.clear();
                                    },
                                  );

                                  // set up the AlertDialog
                                  AlertDialog alert = AlertDialog(
                                    title: const Text(
                                      "To Do:",
                                      textAlign: TextAlign.center,
                                    ),
                                    content: TextField(controller: controller),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  for (int i = 0; i < widget.todos.length; i++)
                    ListTile(
                      leading: Checkbox(
                        value: widget.todos[i].done,
                        onChanged: (newValue) {
                          updateChecked(context.read<String>(),
                              widget.todos[i].id, newValue!);
                        },
                      ),
                      title: Text(
                        widget.todos[i].name,
                        style: TextStyle(
                          decoration: widget.todos[i].done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      onTap: () {
                        updateChecked(widget.user, widget.todos[i].id,
                            !widget.todos[i].done);
                      },
                      onLongPress: () {
                        deleteWithUndo(context, widget.todos[i]);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

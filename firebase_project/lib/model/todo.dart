import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String name;
  String id = '';
  bool done = false;
  DateTime? date;

  Todo({required this.name});

  Todo.fromFirestore(this.id, Map<String, dynamic> json)
      : name = json['name'],
        done = json['done'],
        date = (json['date'] as Timestamp).toDate();
}

Stream<List<Todo>> userTodoSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.collection("/users/$user/todos").orderBy("date").snapshots();
  return stream.map((query) {
    List<Todo> todos = [];
    for (final doc in query.docs) {
      todos.add(Todo.fromFirestore(doc.id, doc.data()));
    }
    return todos;
  });
}

void updateChecked(String user, String docId, bool done) {
  final db = FirebaseFirestore.instance;
  db.doc("users/$user/todos/$docId").update({'done': done});
}

void addTodo(String user, String name, bool done) {
  FirebaseFirestore.instance.collection("/users/$user/todos").add({
    'name': name,
    'done': done,
    'date': Timestamp.now(),
  });
}

//setuser en vez de add user para setear
void deleteTodo(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/users/$user/todos/$docId").delete();
}

void undeleteTodo(String user, Todo todo) {
  final db = FirebaseFirestore.instance;
  db.doc("/users/$user/todos/${todo.id}").set({
    'name': todo.name,
    'done': todo.done,
    'date': Timestamp.fromDate(todo.date!),
  });
}

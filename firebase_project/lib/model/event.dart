import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String name;
  String id = '';
  bool urgency = false;
  late DateTime date;
  //int category;

  Event({required this.name});

  Event.fromFirestore(this.id, Map<String, dynamic> json)
      : name = json['name'],
        urgency = json['urgency'],
        date = (json['date'] as Timestamp).toDate();

  @override
  String toString() => name;
}

Stream<List<Event>> userEventSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.collection("/users/$user/events").orderBy("date").snapshots();
  return stream.map((query) {
    List<Event> events = [];
    for (final doc in query.docs) {
      events.add(Event.fromFirestore(doc.id, doc.data()));
    }
    return events;
  });
}

void addEvent(String user, String name, DateTime date, bool urgency) {
  FirebaseFirestore.instance.collection("/users/$user/events").add({
    'name': name,
    'urgency': urgency,
    'date': date,
  });
}

//setuser en vez de add user para setear
void deleteEvent(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/users/$user/events/$docId").delete();
}

void undeleteEvent(String user, Event event) {
  final db = FirebaseFirestore.instance;
  db.doc("/users/$user/events/${event.id}").set({
    'name': event.name,
    'urgency': event.urgency,
    'date': Timestamp.fromDate(event.date),
  });
}

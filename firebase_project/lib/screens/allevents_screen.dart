import 'package:flutter/material.dart';
import 'package:firebase_project/model/event.dart';

class AllEventsScreen extends StatefulWidget {
  final String user;
  final List<Event> events;
  const AllEventsScreen({Key? key, required this.user, required this.events})
      : super(key: key);
  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents =
        widget.events.where((e) => e.date.isAfter(DateTime.now())).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: Colors.black)),
        backgroundColor: Colors.orange[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        //child: SingleChildScrollView(
        child: Expanded(
          child: ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              //final event = widget.events[index];
              return ListTile(
                leading: Text("time here"),
                title: Text(filteredEvents[index].name),
                trailing: Text("urgencia aqui"),
              );
            },
          ),
        ),
        //),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_project/model/event.dart';

class EventScreen extends StatefulWidget {
  final user;
  final eventController;
  final selectedDay;
  const EventScreen(
      {Key? key, this.user, this.eventController, this.selectedDay})
      : super(key: key);
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late TextEditingController controller;
  // For next delivery
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  bool iosStyle = true;
  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Event",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: Colors.black)),
        backgroundColor: Colors.orange[100],
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Title:",
                  style: TextStyle(fontSize: 22),
                ),
                TextFormField(
                  controller: widget.eventController,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                createInlinePicker(
                  elevation: 1,
                  value: _time,
                  onChange: onTimeChanged,
                  iosStylePicker: iosStyle,
                  minMinute: 0,
                  maxMinute: 59,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Save",
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      onPressed: () {
                        if (widget.eventController.text.isEmpty) {
                          return;
                        }
                        addEvent(widget.user, widget.eventController.text,
                            widget.selectedDay);
                        Navigator.of(context).pop();
                        widget.eventController.clear();
                      },
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}

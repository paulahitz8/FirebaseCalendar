import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_project/model/event.dart';

class EventInfoScreen extends StatefulWidget {
  final user;
  final selectedDay;
  final event;
  const EventInfoScreen({Key? key, this.user, this.selectedDay, this.event})
      : super(key: key);
  @override
  _EventInfoScreenState createState() => _EventInfoScreenState();
}

class _EventInfoScreenState extends State<EventInfoScreen> {
  late TextEditingController controller;
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  bool iosStyle = true;
  DateTime finalDate = DateTime.now();

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.event.name);
    _time = TimeOfDay(
        hour: widget.event.date.hour, minute: widget.event.date.minute);
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
        title: const Text("Event",
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
                TextFormField(
                  controller: controller,
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
                        if (controller.text.isEmpty) {
                          return;
                        }
                        finalDate = DateTime(
                            widget.event.date.year,
                            widget.event.date.month,
                            widget.event.date.day,
                            _time.hour,
                            _time.minute);
                        addEvent(widget.user, controller.text, finalDate);
                        deleteEvent(widget.user, widget.event.id);
                        Navigator.of(context).pop();
                        controller.clear();
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

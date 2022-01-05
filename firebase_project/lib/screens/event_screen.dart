import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_project/model/event.dart';

class EventScreen extends StatefulWidget {
  final user;
  final selectedDay;
  const EventScreen({Key? key, this.user, this.selectedDay}) : super(key: key);
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late TextEditingController controller;
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  bool iosStyle = true;
  DateTime finalDate = DateTime.now();
  bool checkedValue = false;

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
                  controller: controller,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: const Text("Urgent"),
                  value: checkedValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkedValue = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
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
                            widget.selectedDay.year,
                            widget.selectedDay.month,
                            widget.selectedDay.day,
                            _time.hour,
                            _time.minute);
                        addEvent(widget.user, controller.text, finalDate,
                            checkedValue);
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

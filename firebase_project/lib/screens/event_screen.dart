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
  bool iosStyle = false;
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color.fromRGBO(214, 125, 0, 0.7),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            flexibleSpace: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    const Text(
                      "New Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(left: 20),
                      iconSize: 50,
                      icon: Image.asset("assets/honey_bee.png"),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: TextFormField(
                        controller: controller,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text("Urgent"),
                      value: checkedValue,
                      onChanged: (newValue) {
                        setState(() {
                          checkedValue = newValue!;
                        });
                      },
                    ),
                    createInlinePicker(
                      elevation: 2,
                      value: _time,
                      onChange: onTimeChanged,
                      iosStylePicker: iosStyle,
                      minMinute: 0,
                      maxMinute: 59,
                      accentColor: const Color.fromRGBO(214, 125, 0, 0.7),
                      // okCancelStyle: const TextStyle(
                      //   color: Colors.deepOrange,
                      // ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

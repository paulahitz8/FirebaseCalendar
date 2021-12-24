//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_project/model/event.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_project/screens/event_screen.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  final String user;

  const CalendarScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  Map<DateTime, List<Event>> classifyDates(List<Event> events) {
    final Map<DateTime, List<Event>> selectedEvents = {};
    for (final e in events) {
      final d = e.date;
      final dayDate = DateTime.utc(d.year, d.month, d.day);
      //debugPrint(dayDate.toIso8601String());
      if (!selectedEvents.containsKey(dayDate)) {
        selectedEvents[dayDate] = [e];
      } else {
        selectedEvents[dayDate]!.add(e);
      }
    }
    return selectedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: user,
      builder: (context, _) => StreamBuilder(
        stream: userEventSnapshots(user),
        builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case ConnectionState.active:
              return _CalendarScreen(classifyDates(snapshot.data!), user);
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

class _CalendarScreen extends StatefulWidget {
  final String user;
  final Map<DateTime, List<Event>> events;
  const _CalendarScreen(this.events, this.user);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<_CalendarScreen> {
  late TextEditingController controller;

  CalendarFormat format = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    //debugPrint(date.toIso8601String());
    if (widget.events.containsKey(date)) {
      return widget.events[date]!;
    } else {
      return [];
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _eventController.dispose();
    super.dispose();
  }

  void deleteWithUndo(BuildContext context, Event event) {
    deleteEvent(context.read<String>(), event.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You deleted '${event.name}'"),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.amber[900],
          onPressed: () {
            undeleteEvent(context.read<String>(), event);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Calendar",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: Colors.black)),
        backgroundColor: Colors.orange[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    color: Colors.amber[900],
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {},
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(left: 20),
                    iconSize: 50,
                    icon: Image.asset("assets/honey_bee.png"),
                    onPressed: () {},
                  ),
                  IconButton(
                    color: Colors.amber[900],
                    icon: const Icon(Icons.person),
                    onPressed: () {},
                    iconSize: 28,
                  ),
                ],
              ),
              Container(
                height: 2,
                color: Colors.black12,
              ),
              // Calendar
              TableCalendar(
                focusedDay: selectedDay,
                firstDay: DateTime(1990),
                lastDay: DateTime(2050),
                calendarFormat: format,
                onFormatChanged: (CalendarFormat _format) {
                  setState(() {
                    format = _format;
                  });
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekHeight: 25,
                // Day Changed
                onDaySelected: (DateTime selectDay, DateTime focusDay) {
                  setState(() {
                    selectedDay = selectDay;
                    focusedDay = focusDay;
                  });
                },
                selectedDayPredicate: (DateTime date) {
                  return isSameDay(selectedDay, date);
                },

                eventLoader: _getEventsfromDay,

                // Style
                calendarStyle: const CalendarStyle(
                  // Markers Style
                  markersMaxCount: 1,
                  markersAnchor: 1.88,
                  markerSizeScale: 0.13,
                  markerDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),

                  cellMargin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  isTodayHighlighted: true,
                  todayTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                  selectedDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/selected_hexagon.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  todayDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/focused_hexagon.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  defaultDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/hexagon.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  weekendDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/weekend_hexagon.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.amber[900],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.horizontal_rule, size: 30),
                  Icon(Icons.circle, size: 8),
                  Icon(Icons.horizontal_rule, size: 30),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.events[selectedDay] == null)
                      const Text(
                        "Looks like a relaxing day.",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (widget.events[selectedDay] != null)
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
                        backgroundColor: Colors.amber[900],
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventScreen(
                                  user: widget.user,
                                  eventController: _eventController,
                                  selectedDay: selectedDay),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              ..._getEventsfromDay(selectedDay).map(
                (Event event) => ListTile(
                  leading: const Image(
                    image: AssetImage('assets/bee_icon.png'),
                    fit: BoxFit.fitHeight,
                  ),
                  title: Text(
                    event.name,
                  ),
                  trailing: Text(
                    DateFormat('hh:mm a').format(event.date),
                  ),
                  onTap: () {
                    // new window with information about event
                  },
                  onLongPress: () {
                    deleteWithUndo(context, event);
                  },
                ),
              ),
              // This is for next delivery
              // createInlinePicker(
              //   elevation: 1,
              //   value: _time,
              //   onChange: onTimeChanged,
              //   iosStylePicker: iosStyle,
              //   minMinute: 0,
              //   maxMinute: 59,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project/model/event.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  final String user;

  const CalendarScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  Map<DateTime, List<Event>> classifyDates(List<Event> events) {
    final Map<DateTime, List<Event>> selectedEvents = {};
    for (final e in events) {
      final d = e.date!;
      final dayDate = DateTime.utc(d.year, d.month, d.day);
      debugPrint(dayDate.toIso8601String());
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
              return _Screen(classifyDates(snapshot.data!), user);
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

class _Screen extends StatefulWidget {
  final String user;
  final Map<DateTime, List<Event>> events;
  const _Screen(this.events, this.user);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  late TextEditingController controller;

  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool empty = false;

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
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black)),
        backgroundColor: Colors.orange[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FloatingActionButton(
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 26),
                    backgroundColor: Colors.amber[900],
                    onPressed: () {},
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.only(left: 40),
                  iconSize: 70,
                  icon: Image.asset("assets/honey_bee.png"),
                  onPressed: () {},
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FloatingActionButton(
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 30),
                    backgroundColor: Colors.amber[900],
                    onPressed: () {},
                  ),
                ),
              ],
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.horizontal_rule,
                  size: 30,
                ),
                Icon(
                  Icons.circle,
                  size: 8,
                ),
                Icon(
                  Icons.horizontal_rule,
                  size: 30,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                if (widget.events[selectedDay] != null)
                  const Text(
                    "Plans for the day:",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (widget.events[selectedDay] == null)
                  const Text(
                    "Looks like a relaxing day.",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            // ListView.builder(
            //     itemCount: widget.events[selectedDay]!.length,
            //     itemBuilder: (context, index) {
            //       final Event event = widget.events[selectedDay]![index];
            //       return ListTile(
            //         leading: const Image(
            //           image: AssetImage('assets/bee_icon.png'),
            //           fit: BoxFit.fitHeight,
            //         ),
            //         title: Text(
            //           event.name,
            //         ),
            //         onTap: () {
            //           // new window with information about event
            //         },
            //         onLongPress: () {
            //           deleteWithUndo(context, event);
            //         },
            //       );
            //     }),
            ..._getEventsfromDay(selectedDay).map(
              (Event event) =>
                  // (Event event) => ListView(
                  //   children: <Widget>[
                  ListTile(
                leading: const Image(
                  image: AssetImage('assets/bee_icon.png'),
                  fit: BoxFit.fitHeight,
                ),
                title: Text(
                  event.name,
                ),
                onTap: () {
                  // new window with information about event
                },
                onLongPress: () {
                  deleteWithUndo(context, event);
                },
              ),
              //],
            ),
            // (Event event) => ListTile(
            //   leading: const Image(
            //     image: AssetImage('assets/bee_icon.png'),
            //     fit: BoxFit.fitHeight,
            //   ),
            //   title: Text(
            //     event.name,
            //   ),
            //   onTap: () {
            //     // new window with information about event
            //   },
            //   onLongPress: () {
            //     deleteWithUndo(context, event);
            //   },
            // ),
            // ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.amber[900],
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Add Event"),
                      content: TextFormField(
                        controller: _eventController,
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel",
                              style: TextStyle(
                                color: Colors.black,
                              )),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text("Ok",
                              style: TextStyle(
                                color: Colors.black,
                              )),
                          onPressed: () {
                            if (_eventController.text.isEmpty) {
                              return;
                            }
                            addEvent(widget.user, _eventController.text,
                                selectedDay);
                            Navigator.pop(context);
                            _eventController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                  label: const Text("Add Event"),
                  icon: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

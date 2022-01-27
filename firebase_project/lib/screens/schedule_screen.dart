import 'package:flutter/material.dart';
import 'package:firebase_project/model/event.dart';
import 'package:firebase_project/screens/event_info_screen.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatelessWidget {
  final String user;
  final List<Event> events;
  final DateTime selectedDay;
  const ScheduleScreen(
      {Key? key,
      required this.user,
      required this.events,
      required this.selectedDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredEvents =
        events.where((e) => e.date.isAfter(DateTime.now())).toList();

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
                      "Schedule",
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
                for (int i = 0; i < filteredEvents.length; i++)
                  ListTile(
                    trailing: Text(
                      DateFormat('d/M   hh:mm a')
                          .format(filteredEvents[i].date),
                    ),
                    title: Text(
                      filteredEvents[i].name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    tileColor: filteredEvents[i].urgency
                        ? Colors.orange[50]
                        : Colors.white,
                    leading: const Image(
                      width: 40,
                      height: 40,
                      image: AssetImage('assets/bee_icon.png'),
                      fit: BoxFit.fitHeight,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventInfoScreen(
                              user: user,
                              selectedDay: selectedDay,
                              event: filteredEvents[i]),
                        ),
                      );
                    },
                    // onLongPress: () {
                    //   deleteWithUndo(context, event);
                    // },
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

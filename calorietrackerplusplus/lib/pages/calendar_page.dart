import 'dart:collection';

import 'package:calorietrackerplusplus/log_calories_dialog.dart';
import 'package:calorietrackerplusplus/set_goal_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:provider/provider.dart';
import 'package:calorietrackerplusplus/app_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:calorietrackerplusplus/src/authentication.dart';
import 'package:calorietrackerplusplus/src/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>( // From https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/utils.dart
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource);

final _kEventSource = { for (var item in List.generate(50, (index) => index)) DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5) : List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')) }
  ..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
  final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
  final kToday = DateTime.now();

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    super.initState();
  }

  List<Event> _getEventsForDay(DateTime day) {
              return kEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 1.5),
        ),
        title: const Text('Calendar'), backgroundColor: const Color.fromARGB(255, 165, 244, 20),
      ),
      body: Column(
        children: [
          TableCalendar(  // A lot of this code is from the PubDev documentation  https://pub.dev/packages/table_calendar
            focusedDay: DateTime.now(),
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2025, 12, 30),

            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
          ),
        ],
      ),
    );
  }
}
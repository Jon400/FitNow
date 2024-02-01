import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../account/index.dart';

class ActivityTimeButton extends StatefulWidget {
  @override
  _ActivityTimeButtonState createState() => _ActivityTimeButtonState();
}

class _ActivityTimeButtonState extends State<ActivityTimeButton> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),
    AccountScreen(),
  ];

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting of my activity time'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showCalendar();
            },
            child: Text("Open Calendar"),
          ),
          Expanded(
            child: Center(
              child: _pageOptions[_selectedPage],
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2024, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement logic to save the selected availability
                  // You can pass _selectedDay to another screen or function to handle availability
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Text("Save Availability"),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityTimeButton extends StatefulWidget {
  @override
  _ActivityTimeButtonState createState() => _ActivityTimeButtonState();
}

class _ActivityTimeButtonState extends State<ActivityTimeButton> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay _startWorkingTime = TimeOfDay(hour: 8, minute: 0);
  int _hoursOfWork = 8;

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
              _openCalendarScreen();
            },
            child: Text("Open Calendar"),
          ),
          Expanded(
            child: Center(
              child: Text("Current Page Content"),
            ),
          ),
        ],
      ),
    );
  }

  void _openCalendarScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarScreen(
          startWorkingTime: _startWorkingTime,
          hoursOfWork: _hoursOfWork,
          onHoursSelected: (startWorkingTime, hoursOfWork) {
            setState(() {
              _startWorkingTime = startWorkingTime;
              _hoursOfWork = hoursOfWork;
            });
          },
        ),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final TimeOfDay startWorkingTime;
  final int hoursOfWork;
  final Function(TimeOfDay, int) onHoursSelected;

  CalendarScreen({
    required this.startWorkingTime,
    required this.hoursOfWork,
    required this.onHoursSelected,
  });

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Screen'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          if (_selectedDay != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Selected Day: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Start Working Time:'),
                  ListTile(
                    title: Text(
                      _getTimeOfDayString(widget.startWorkingTime),
                    ),
                    onTap: () {
                      _showTimePicker(widget.startWorkingTime, (selectedTime) {
                        setState(() {
                          widget.onHoursSelected(selectedTime, widget.hoursOfWork);
                        });
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Text('Hours of Work:'),
                  ListTile(
                    title: Text('${widget.hoursOfWork} hours'),
                    onTap: () {
                      _showHoursPicker(widget.hoursOfWork, (selectedHours) {
                        setState(() {
                          widget.onHoursSelected(widget.startWorkingTime, selectedHours);
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the current screen
            },
            child: Text("Save Availability"),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDayString(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker(TimeOfDay initialTime, Function(TimeOfDay) onTimeSelected) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      onTimeSelected(selectedTime);
    }
  }

  Future<void> _showHoursPicker(int initialHours, Function(int) onHoursSelected) async {
    int? selectedHours = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Hours of Work'),
          children: List.generate(
            12,
                (index) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, (index + 1) * 2), // Increment by 2 hours each option
              child: Text('${(index + 1) * 2} hours'),
            ),
          ),
        );
      },
    );

    if (selectedHours != null) {
      onHoursSelected(selectedHours);
    }
  }
}

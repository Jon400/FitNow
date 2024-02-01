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
  List<Map<String, TimeOfDay>> _workingTimes = [];

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
          workingTimes: List.from(_workingTimes),
          onTimeRangesSelected: (workingTimes) {
            setState(() {
              _workingTimes = List.from(workingTimes);
            });
          },
        ),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final List<Map<String, TimeOfDay>> workingTimes;
  final Function(List<Map<String, TimeOfDay>>) onTimeRangesSelected;

  CalendarScreen({
    required this.workingTimes,
    required this.onTimeRangesSelected,
  });

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, TimeOfDay>> _workingTimes = [];

  @override
  void initState() {
    super.initState();
    _workingTimes = List.from(widget.workingTimes);
  }

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
                  Text('Working Times:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _workingTimes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            '${_getTimeOfDayString(_workingTimes[index]['start']!)} - ${_getTimeOfDayString(_workingTimes[index]['end']!)}',
                          ),
                          onTap: () {
                            _showTimeRangePicker(
                              _workingTimes[index]['start']!,
                              _workingTimes[index]['end']!,
                                  (start, end) {
                                setState(() {
                                  _workingTimes[index]['start'] = start;
                                  _workingTimes[index]['end'] = end;
                                  widget.onTimeRangesSelected(_workingTimes);
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addTimeRange();
                    },
                    child: Text("Add Time Range"),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: () {
              widget.onTimeRangesSelected(_workingTimes);
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

  Future<void> _showTimeRangePicker(
      TimeOfDay initialStart,
      TimeOfDay initialEnd,
      Function(TimeOfDay, TimeOfDay) onTimeRangeSelected,
      ) async {
    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: initialStart,
    );

    if (start != null) {
      TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: initialEnd,
      );

      if (end != null) {
        onTimeRangeSelected(start, end);
      }
    }
  }

  void _addTimeRange() {
    _showTimeRangePicker(
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 10, minute: 0),
          (start, end) {
        setState(() {
          _workingTimes.add({'start': start, 'end': end});
        });
      },
    );
  }
}

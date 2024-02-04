import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/app_user.dart';
import '../../models/trainer.dart';

class ActivityTimeButton extends StatefulWidget {
  @override
  _ActivityTimeButtonState createState() => _ActivityTimeButtonState();
}

class _ActivityTimeButtonState extends State<ActivityTimeButton> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TimeRange> _workingTimes = [];
  late TrainerProfile _trainerProfile;

  @override
  void initState() {
    super.initState();
    final appUser = Provider.of<AppUser?>(context, listen: false);
    _trainerProfile = TrainerProfile(
      pid: appUser!.uid,
      roleView: '',
      firstName: '',
      lastName: '',
      logoUrl: '',
      description: '',
      sport: '',
      specializations: [],
    );
    _listenToAvailability();
  }

  void _listenToAvailability() {
    // Listening to the trainer's availability
    _trainerProfile.getAvailabilityTime().listen((timeSlots) {
      setState(() {
        _workingTimes = timeSlots;
      });
    });
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
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color:  Color(0xFF7B6F72), // Change button's background color
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF9DCEFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _workingTimes.length,
              itemBuilder: (context, index) {
                final timeRange = _workingTimes[index];
                if (_selectedDay != null &&
                    isSameDay(_selectedDay, timeRange.startTime)) {
                  return ListTile(
                    title: Text(
                      '${timeRange.startTime.hour.toString().padLeft(2, '0')}:${timeRange.startTime.minute.toString().padLeft(2, '0')} - ${timeRange.endTime.hour.toString().padLeft(2, '0')}:${timeRange.endTime.minute.toString().padLeft(2, '0')}',
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addTimeRange,
            style: ElevatedButton.styleFrom(
              primary:  Color(0xFF92A3FD), // Change button's background color
              onPrimary: Colors.white, // Change text color

            ),
            child: Text("Select Time Range"), // Change button's text
          ),
        ],
      ),
    );
  }

  Future<void> _showTimeRangePicker(DateTime initialStart, DateTime initialEnd,
      Function(DateTime, DateTime) onTimeRangeSelected) async {
    TimeOfDay initialStartTime =
        TimeOfDay(hour: initialStart.hour, minute: initialStart.minute);
    TimeOfDay initialEndTime =
        TimeOfDay(hour: initialEnd.hour, minute: initialEnd.minute);

    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: initialStartTime,
    );

    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: initialEndTime,
    );

    if (endTime == null) return;

    DateTime startDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      startTime.hour,
      startTime.minute,
    );
    DateTime endDateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      endTime.hour,
      endTime.minute,
    );

    onTimeRangeSelected(startDateTime, endDateTime);
  }

  void _addTimeRange() {
    if (_selectedDay == null) return;

    DateTime now = DateTime.now();
    DateTime initialStart = DateTime(now.year, now.month, now.day, 8, 0);
    DateTime initialEnd = DateTime(now.year, now.month, now.day, 10, 0);

    _showTimeRangePicker(initialStart, initialEnd,
        (DateTime start, DateTime end) {
      TimeRange newTimeRange = TimeRange(startTime: start, endTime: end);
      _trainerProfile.createAvailabilityTime(newTimeRange).then((_) {
        // Optionally refresh the list or show a success message
      }).catchError((error) {
        // Handle errors, such as showing an error message
      });
    });
  }
}

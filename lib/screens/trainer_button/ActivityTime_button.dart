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
    if (mounted) {
      setState(() {
        _focusedDay = DateTime.now();
      });
    }
    _listenToAvailability();
  }

  void _listenToAvailability() {
    // Assuming getAvailabilityTime returns a Stream
    _trainerProfile.getAvailabilityTime().listen((timeSlots) {
      if (mounted) {
        // Check if the widget is still in the widget tree
        setState(() {
          _workingTimes = timeSlots;
          // sort the time slots by start time
          _workingTimes.sort((a, b) => a.startTime.compareTo(b.startTime));
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Activity Time',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Set the background color of the container
              borderRadius: BorderRadius.circular(10), // Add rounded corners
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                weekendTextStyle: TextStyle(
                  color: Colors.blue, // Change text color
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey, // Change button's background color
                  shape: BoxShape.rectangle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.amber, // Change button's background color
                  shape: BoxShape.rectangle,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Colors.blue, // Change text color
                  fontWeight: FontWeight.bold,

                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.black, // Change text color
                  fontWeight: FontWeight.bold,

                ),
                weekendStyle: TextStyle(
                  color: Colors.blue, // Change text color
                  fontWeight: FontWeight.bold,

                ),
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
                  // Convert time to a more user-friendly format
                  String startTime =
                      '${timeRange.startTime.hour.toString().padLeft(2, '0')}:${timeRange.startTime.minute.toString().padLeft(2, '0')}';
                  String endTime =
                      '${timeRange.endTime.hour.toString().padLeft(2, '0')}:${timeRange.endTime.minute.toString().padLeft(2, '0')}';
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        '$startTime - $endTime',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      //subtitle: Text('Available Time Range'),
                      trailing: Wrap(
                        spacing: 12, // space between two icons
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editTimeRange(timeRange),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeTimeRange(timeRange),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container(); // Return an empty container for non-matching days
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addTimeRange,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.blue, //Change text color
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
        // show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Time Range Added"),
          backgroundColor: Colors.green,
        ));
      }).catchError((error) {
        // show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          // remove the word "Excetpion" from the error message "error"
          content: Text("Error Adding Time Range - $error"),
          backgroundColor: Colors.red,
        ));
      });
    });
  }

  void _removeTimeRange(TimeRange timeRange) {
    _trainerProfile.removeAvailabilityTime(timeRange).then((_) {
      // show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Time Range Removed"),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      // show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error Removing Time Range - $error"),
        backgroundColor: Colors.red,
      ));
    });
  }

  void _editTimeRange(TimeRange timeRange) {
    _showTimeRangePicker(timeRange.startTime, timeRange.endTime,
        (DateTime start, DateTime end) {
      TimeRange newTimeRange = TimeRange(startTime: start, endTime: end);
      _trainerProfile.updateAvailabilityTime(timeRange, newTimeRange).then((_) {
        // show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Time Range Updated"),
          backgroundColor: Colors.green,
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error Updating Time Range - $error"),
          backgroundColor: Colors.red,
        ));
      });
    });
  }
}

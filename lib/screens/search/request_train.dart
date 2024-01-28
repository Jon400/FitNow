import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/trainer.dart'; // Ensure this path is correct

class RequestTrainingScreen extends StatefulWidget {
  @override
  _RequestTrainingScreenState createState() => _RequestTrainingScreenState();
}

class _RequestTrainingScreenState extends State<RequestTrainingScreen> {
  TrainerProfile? trainerProfile;
  List<TimeRange> availableTimeSlots = [];
  List<String> specializations = [];
  DateTimeRange? selectedTimeRange;
  String? selectedSpecialization;

  @override
  void initState() {
    super.initState();
    trainerProfile = Provider.of<TrainerProfile>(context, listen: false);
    fetchAvailableTimeSlots();
    fetchSpecializations();
  }

  void fetchAvailableTimeSlots() async {
    final now = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final end = now.add(Duration(days: 7));

    try {
      List<TimeRange> timeSlots = (await trainerProfile!.getAvailableTimeSlots(now, end).first).cast<TimeRange>();
      setState(() {
        availableTimeSlots = timeSlots;
      });
    } catch (error) {
      print('Error fetching time slots: $error');
    }
  }

  void fetchSpecializations() {
    trainerProfile!.getSpecializations().listen((fetchedSpecializations) {
      setState(() {
        specializations = fetchedSpecializations;
      });
    }, onError: (error) {
      print('Error fetching specializations: $error');
    });
  }

  void showCustomTimePickerDialog(DateTime startTime, DateTime endTime) async {
    final DateTimeRange? pickedRange = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => CustomTimePickerDialog(
        availableTimeSlots: [TimeRange(startTime: startTime, endTime: endTime)],
        initialTimeRange: selectedTimeRange,
      ),
    );

    if (pickedRange != null) {
      setState(() {
        selectedTimeRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Training Time'),
      ),
      body: Column(
        children: [
          Text(
            'Select Training Session With ${trainerProfile?.firstName ?? "N/A"} ${trainerProfile?.lastName ?? ""}',
            style: TextStyle(fontSize: 17),
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.week,
              dataSource: MeetingDataSource(availableTimeSlots),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  final Appointment appointment = details.appointments!.first;
                  showCustomTimePickerDialog(appointment.startTime, appointment.endTime);
                }
              },
            ),
          ),
          if (selectedTimeRange != null) Padding(
            padding: EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedSpecialization,
              hint: Text("Select Specialization"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSpecialization = newValue;
                });
              },
              items: specializations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: selectedTimeRange != null
                ? Text(
              'Selected Time Range: ${selectedTimeRange!.start.toLocal()} to ${selectedTimeRange!.end.toLocal()}',
              style: TextStyle(fontSize: 18),
            )
                : Text(
              'No Time Range Selected',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedTimeRange != null) {
                print('Selected Time Range: ${selectedTimeRange!.start.toLocal()} to ${selectedTimeRange!.end.toLocal()}');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<TimeRange> source) {
    appointments = source.map((timeRange) => Appointment(
      startTime: timeRange.startTime,
      endTime: timeRange.endTime,
      isAllDay: false,
      subject: 'Available Slot',
      color: Colors.green,
    )).toList();
  }
}

class CustomTimePickerDialog extends StatefulWidget {
  final List<TimeRange> availableTimeSlots;
  final DateTimeRange? initialTimeRange;

  CustomTimePickerDialog({Key? key, required this.availableTimeSlots, this.initialTimeRange}) : super(key: key);

  @override
  _CustomTimePickerDialogState createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  Future<void> selectTime(DateTime initialDate, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime != null) {
      DateTime updatedDateTime = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (isWithinAvailableSlot(updatedDateTime, isStartTime)) {
        setState(() {
          if (isStartTime) {
            selectedStartTime = updatedDateTime;
          } else {
            selectedEndTime = updatedDateTime;
          }
        });
      } else {
        showInvalidTimeDialog();
      }
    }
  }

  bool isWithinAvailableSlot(DateTime time, bool isStartTime) {
    for (var slot in widget.availableTimeSlots) {
      if (isStartTime) {
        if (time.isAfter(slot.startTime) && time.isBefore(slot.endTime)) {
          return true;
        }
      } else {
        if (time.isAfter(selectedStartTime ?? DateTime.now()) && time.isBefore(slot.endTime)) {
          return true;
        }
      }
    }
    return false;
  }

  void showInvalidTimeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invalid Time"),
          content: Text("Selected time is outside of available slots."),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // clear the selected time
                setState(() {
                  selectedStartTime = null;
                  selectedEndTime = null;
                });
                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Time Range'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.availableTimeSlots.map((timeSlot) {
            return ListTile(
              title: Text('${timeSlot.startTime} - ${timeSlot.endTime}'),
              onTap: () {
                setState(() {
                  selectedStartTime = timeSlot.startTime;
                  selectedEndTime = timeSlot.endTime;
                });
                selectTime(timeSlot.startTime, true).then((_) => selectTime(timeSlot.endTime, false));
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            if (selectedStartTime != null && selectedEndTime != null) {
              Navigator.of(context). pop(DateTimeRange(start: selectedStartTime!, end: selectedEndTime!));
            }
          },
        ),
      ],
    );
  }
}

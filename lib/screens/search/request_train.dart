import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/app_user.dart';
import '../../models/trainer.dart'; // Ensure this path is correct
import '../../models/training_session.dart'; // Ensure this path is correct
import 'package:intl/intl.dart';


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
  AppUser? currUser;
  bool _isSubmitButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    trainerProfile = Provider.of<TrainerProfile>(context, listen: false);
    currUser = Provider.of<AppUser>(context, listen: false)!;
    _isSubmitButtonEnabled = true;
    fetchSpecializations();
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
      builder: (context) =>
          CustomTimePickerDialog(
            availableTimeSlots: [
              TimeRange(startTime: startTime, endTime: endTime)
            ],
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
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Select Training Time', style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),

    ),
      body: Column(
        children: [
          Text(
            'Select Training Session With ${trainerProfile?.firstName ??
                "N/A"} ${trainerProfile?.lastName ?? ""}',
            style: TextStyle(fontSize: 17),
          ),
          Expanded(
            child: StreamBuilder<List<TimeRange>>(
              stream: trainerProfile!.getAvailableTimeSlots(
                  DateTime.now().subtract(Duration(days: 30)),
                  DateTime.now().add(Duration(days: 30))
              ),
              builder: (context, availableSnapshot) {
                if (availableSnapshot.hasData) {
                  return StreamBuilder<List<TimeRange>>(
                    stream: trainerProfile!.getBookedTimeSlots(
                        DateTime.now().subtract(Duration(days: 30)),
                        DateTime.now().add(Duration(days: 30))
                    ),
                    builder: (context, bookedSnapshot) {
                      if (bookedSnapshot.hasData) {
                        return SfCalendar(
                          view: CalendarView.week,
                          dataSource: MeetingDataSource(availableSnapshot.data!, bookedSnapshot.data!),
                          onTap: (CalendarTapDetails details) {
                            if (details.targetElement == CalendarElement.appointment) {
                              final Appointment appointment = details.appointments!.first;
                              if (appointment.subject == 'Booked Slot') {
                                return;
                              }
                              showCustomTimePickerDialog(appointment.startTime, appointment.endTime);
                            }
                          },
                        );
                      } else if (bookedSnapshot.hasError) {
                        return Text('Error fetching booked time slots: ${bookedSnapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                } else if (availableSnapshot.hasError) {
                  return Text('Error fetching available time slots: ${availableSnapshot.error}');
                } else {
                  return Center(child: CircularProgressIndicator());
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
              items: specializations.map<DropdownMenuItem<String>>((
                  String value) {
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
              // do it in friendly format uusing intl
              'Selected Time Range: ${DateFormat('dd MMM yyyy, hh:mm a').format(selectedTimeRange!.start)} - ${DateFormat('hh:mm a').format(selectedTimeRange!.end)}',
              style: TextStyle(fontSize: 18),
            )
                : Text(
              'No Time Range Selected',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: !_isSubmitButtonEnabled ? null : () async {
              if (selectedTimeRange == null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("Please select a time range."),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                return;
              }
              else if (selectedSpecialization == null) {
                // show error dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("Please select a specialization."),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                return;
              }
              if (selectedTimeRange != null) {
                print('Selected Time Range: ${selectedTimeRange!.start
                    .toLocal()} to ${selectedTimeRange!.end.toLocal()}');
              }
              if (selectedSpecialization != null) {
                print('Selected Specialization: $selectedSpecialization');
              }
              // call a function to create the training session  void submitTrainingSession()
              submitTrainingSession();
            },
            child: Text('Submit', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: Colors.amber,
              elevation: 2,
            )

          ),
        ],

      ),
    );
  }


  void submitTrainingSession() async {
    if (!_isSubmitButtonEnabled) return; // Prevent multiple submissions

    // Create a new training session
    TrainingSession trainingSession = TrainingSession(
      tid: '',
      startTime: selectedTimeRange!.start,
      endTime: selectedTimeRange!.end,
      sport: trainerProfile!.sport,
      spec: selectedSpecialization!,
      traineeId: currUser!.uid,
      trainerId: trainerProfile!.pid,
      status: 'pending',
    );

    try {
      await trainingSession.createTrainingSession(
          trainerProfile!.pid,
          currUser!.uid,
          selectedTimeRange!.start,
          selectedTimeRange!.end,
          trainerProfile!.sport,
          selectedSpecialization!
      );

      // On success, show success dialog and grey out the button
      setState(() {
        _isSubmitButtonEnabled = false; // Grey out the button
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Request sent successfully."),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // On failure, show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to send the request.\n" + e.toString()),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }
}


class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<TimeRange> availableSlots, List<TimeRange> bookedSlots) {
    final List<Appointment> _appointments = [];

    // Available slots - green
    _appointments.addAll(availableSlots.map(
          (timeRange) => Appointment(
        startTime: timeRange.startTime,
        endTime: timeRange.endTime,
        isAllDay: false,
        subject: 'Available Slot',
        color: Colors.green,
      ),
    ));

    // Booked slots - red
    // do it unclickable
    _appointments.addAll(bookedSlots.map(
          (timeRange) => Appointment(
        startTime: timeRange.startTime,
        endTime: timeRange.endTime,
        isAllDay: false,
        subject: 'Booked Slot',
        color: Colors.red,
      ),
    ));

    appointments = _appointments;
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

  @override
  void initState() {
    super.initState();
    if (widget.initialTimeRange != null) {
      selectedStartTime = widget.initialTimeRange!.start;
      selectedEndTime = widget.initialTimeRange!.end;
    }
  }

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
        if (time.isAtSameMomentAs(slot.startTime) || (time.isAfter(slot.startTime) && time.isBefore(slot.endTime))) {
          return true;
        }
      } else {
        if (selectedStartTime != null && time.isAfter(selectedStartTime!) && time.isBefore(slot.endTime)) {
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
              onPressed: () => Navigator.of(context).pop(),
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
              title: Text('Time Slot: ${DateFormat('dd MMM yyyy, hh:mm a').format(timeSlot.startTime)} - ${DateFormat('hh:mm a').format(timeSlot.endTime)}', style: TextStyle(color: Colors.black)),
                  onTap: () {
                selectTime(timeSlot.startTime, true).then((_) {
                  // choose the text "choose end time" if the start time is selected

                  if (selectedStartTime != null) {
                    selectTime(timeSlot.endTime, false);
                  }
                }// else on the then block
                );
              },
              // show the slected time range if both start and end time are selected
              subtitle: (selectedStartTime != null && selectedEndTime != null)
                  ? Text('Selected: ${DateFormat('dd MMM yyyy, hh:mm a').format(selectedStartTime!)} - ${DateFormat('hh:mm a').format(selectedEndTime!)}')
                  : null,
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        // show the slected time range if both start and end time are selected
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: (selectedStartTime != null && selectedEndTime != null) ? () {
            Navigator.of(context).pop(DateTimeRange(start: selectedStartTime!, end: selectedEndTime!));
          } : null,
        ),
      ],
    );
  }
}

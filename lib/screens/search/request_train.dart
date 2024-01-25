import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/trainer.dart';

class RequestTrainingScreen extends StatefulWidget {
  @override
  _RequestTrainingScreenState createState() => _RequestTrainingScreenState();
}

class _RequestTrainingScreenState extends State<RequestTrainingScreen> {
  TrainerProfile? trainerProfile;
  List<TimeRange> availableTimeSlots = [];

  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  @override
  void initState() {
    super.initState();
    trainerProfile = Provider.of<TrainerProfile>(context, listen: false);
    fetchAvailableTimeSlots();
  }

  void fetchAvailableTimeSlots() {
    final now = DateTime.now();
    final end = now.add(Duration(days: 7));
    trainerProfile!.getAvailableTimeSlots(now, end).listen((timeSlots) {
      setState(() {
        availableTimeSlots = timeSlots;
      });
    });
  }

  void handleTimeRangeSelection(DateTime startTime, DateTime endTime) {
    setState(() {
      selectedStartTime = startTime;
      selectedEndTime = endTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Training Time'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selected Time Range:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          if (selectedStartTime != null && selectedEndTime != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Start Time: ${selectedStartTime!.toLocal()}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          if (selectedStartTime != null && selectedEndTime != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'End Time: ${selectedEndTime!.toLocal()}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.day,
              appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Center(
                    child: Text(
                      'Available Slot',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  final startTime = details.appointments?[0].startTime;
                  final endTime = details.appointments?[0].endTime;
                  handleTimeRangeSelection(startTime, endTime);
                }
              },
              onLongPress: (CalendarLongPressDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  final startTime = details.appointments?[0].startTime;
                  final endTime = startTime.add(Duration(minutes: 30));
                  handleTimeRangeSelection(startTime, endTime);
                }
              },
              dataSource: MeetingDataSource(availableTimeSlots),
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<TimeRange> source) {
    appointments = source
        .map((timeRange) => Appointment(
      startTime: timeRange.startTime,
      endTime: timeRange.endTime,
      isAllDay: false,
    ))
        .toList();
  }
}

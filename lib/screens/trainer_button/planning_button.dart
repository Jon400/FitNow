import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class planning_button extends StatefulWidget {
  @override
  _planning_buttonState createState() => _planning_buttonState();
}

class _planning_buttonState extends State<planning_button> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TrainingSession> _trainingSessions = [];

  @override
  void initState() {
    super.initState();
    fetchTrainingSessions();
  }

  void fetchTrainingSessions() {
    _firestore
        .collection('training_sessions')
        .where('status', isEqualTo: 'approved')
        .get()
        .then((QuerySnapshot querySnapshot) {
          setState(() {
            _trainingSessions = querySnapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return TrainingSession(
                  id: doc.id,
                  startTime: (data['startTime'] as Timestamp).toDate(),
                  endTime: (data['endTime'] as Timestamp).toDate(),
                  // Autres champs si nécessaire
               );
              })
              .toList();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Planning'),
      ),
      body: Column(
        children: [
          SfCalendar(
            view: CalendarView.month,
            dataSource: TrainingSessionDataSource(_trainingSessions),
            monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
          )
        ],
      ),
    );
  }
}

class TrainingSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  TrainingSession({
    required this.id,
    required this.startTime,
    required this.endTime,
  });
}

class TrainingSessionDataSource extends CalendarDataSource {
  TrainingSessionDataSource(List<TrainingSession> appointments) {
    this.appointments = appointments;
  }

  @override
  DateTime getStartTime(int index) {
    //final TrainingSession trainingSession = appointments![index] as TrainingSession;
    //return trainingSession.startTime;
    return (appointments![index] as TrainingSession).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    //final TrainingSession trainingSession = appointments![index] as TrainingSession;
    //return trainingSession.endTime;
    return (appointments![index] as TrainingSession).endTime;
  }

  @override
  String getSubject(int index) {
    //final TrainingSession trainingSession = appointments![index] as TrainingSession;
    //return 'Session: ${trainingSession.id}';
    return 'Training Session: ${(appointments![index] as TrainingSession).id}';
  }

  @override
  Color getColor(int index) {
    return Colors.blue; // You can change this color as needed
  }
}

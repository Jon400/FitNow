import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class planning_button extends StatefulWidget {
  @override
  _planning_buttonState createState() => _planning_buttonState();
}

class _planning_buttonState extends State<planning_button> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TrainingSession> _trainingSessions = [];
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<TrainingSession>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _events = {};
    fetchTrainingSessions();
  }

  void fetchTrainingSessions() {
    _firestore.collection('training_sessions').get().then((QuerySnapshot querySnapshot) {
      setState(() {
        _trainingSessions = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return TrainingSession(
            id: doc.id,
            startTime: data['startTime'],
            endTime: data['endTime'],
          );
        }).toList();
        _generateEvents();
      });
    });
  }

  void _generateEvents() {
    for (var session in _trainingSessions) {
      DateTime startTime = session.startTime.toDate();
      DateTime dateKey = DateTime(startTime.year, startTime.month, startTime.day);
      if (_events[dateKey] == null) _events[dateKey] = [];
      _events[dateKey]!.add(session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Planning'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2040, 1, 1),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => _events[day] ?? [],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _trainingSessions.length,
              itemBuilder: (context, index) {
                final trainingSession = _trainingSessions[index];
                return ListTile(
                  title: Text('ID: ${trainingSession.id}'),
                  subtitle: Text('Start Time: ${DateFormat('dd MMM yyyy HH:mm:ss').format(trainingSession.startTime.toDate())}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingSession {
  final String id;
  final Timestamp startTime;
  final Timestamp endTime;

  TrainingSession({
    required this.id,
    required this.startTime,
    required this.endTime,
  });
}

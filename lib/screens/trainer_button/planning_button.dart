import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/app_user.dart';
import '../../models/profile.dart';
import '../../models/training_session.dart';
import '../../services/database.dart';

class planning_button extends StatefulWidget {
  @override
  _PlanningScreenState createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<planning_button> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TrainingSession> _trainingSessions = [];
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<TrainingSession>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _fetchTrainingSessions();
  }

  void _fetchTrainingSessions() async {
    try {
      final appUser = Provider.of<AppUser?>(context, listen: false);
      if (appUser != null) {
        var querySnapshot = await _firestore
            .collection('training_sessions')
            .where('trainerId', isEqualTo: appUser.uid)
            .where('status', isEqualTo: 'approved')
            .orderBy('startTime')
            .get();

        _trainingSessions = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return TrainingSession(
            tid: doc.id,
            startTime: data['startTime'].toDate(),
            endTime: data['endTime'].toDate(),
            sport: data['sport'],
            spec: data['spec'],
            status: data['status'],
            traineeId: data['traineeId'],
            trainerId: data['trainerId'],
          );
        }).toList();

        _generateEvents();
      }
    } catch (e) {
      // Handle errors here
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateEvents() {
    _events = {};
    for (var session in _trainingSessions) {
      DateTime dateKey = DateTime(session.startTime!.year, session.startTime!.month, session.startTime!.day);
      if (!_events.containsKey(dateKey)) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(session);
    }
  }

  List<TrainingSession> _getSessionsForSelectedDay() {
    DateTime dateKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    return _events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
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
              itemCount: _getSessionsForSelectedDay().length,
              itemBuilder: (context, index) {
                final trainingSession = _getSessionsForSelectedDay()[index];
                // Use a StreamBuilder to fetch and display trainer names
                return StreamBuilder<Profile>(
                  stream: DatabaseService(uid: trainingSession.traineeId, roleView: 'trainee').profile,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Profile traineeProfile = snapshot.data!;
                      return ListTile(
                        title: Text('Trainee: ${traineeProfile.firstName} ${traineeProfile.lastName}'),
                        subtitle: Text('${DateFormat('HH:mm').format(trainingSession.startTime)}' +
                            ' -  ${DateFormat('HH:mm').format(trainingSession.endTime)}'),
                      );
                    } else {
                      return ListTile(
                        title: Text('Loading trainer name...'),
                        subtitle: Text('Start Time: ${DateFormat('dd MMM yyyy HH:mm:ss').format(trainingSession.startTime)}\n' +
                            'End Time: ${DateFormat('dd MMM yyyy HH:mm:ss').format(trainingSession.endTime)}'),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

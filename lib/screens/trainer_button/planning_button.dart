import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/training_session2.dart';
import '../../services/database.dart';

class PlanningButton extends StatefulWidget {
  @override
  _PlanningButtonState createState() => _PlanningButtonState();
}

class _PlanningButtonState extends State<PlanningButton> {
  List<TrainingSession> _approvedTrainingSessions = [];

  @override
  void initState() {
    super.initState();
    _getApprovedTrainingSessions();
  }

  Future<void> _getApprovedTrainingSessions() async {
    final databaseService = DatabaseService(uid: 'your_user_id', roleView: '');
    final approvedTrainingSessions = await databaseService.getApprovedTrainingSessions();

    setState(() {
      _approvedTrainingSessions = approvedTrainingSessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.month, // Choisissez la vue de calendrier appropriée selon vos besoins
      dataSource: TrainingSessionDataSource(_approvedTrainingSessions),
      // Autres propriétés de configuration du calendrier
    );
  }
}

class TrainingSessionDataSource extends CalendarDataSource {
  TrainingSessionDataSource(List<TrainingSession> source) {
    appointments = source
        .map((trainingSession) => Appointment(
      startTime: training_sessions.startTime,
      endTime: trainingSession.endTime,
      subject: trainingSession.spec, // Remplacez 'spec' par le nom de la propriété que vous souhaitez afficher.
      // Vous pouvez également ajouter d'autres informations à afficher ici.
    ))
        .toList();
  }
}

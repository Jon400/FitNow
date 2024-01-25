// training_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingSession {
  final String sessionId;
  final Timestamp endTime;
  final String spec;
  final String sport;
  final Timestamp startTime;
  final String status;
  final String traineeId;
  final String trainerId;

  TrainingSession({
    required this.sessionId,
    required this.endTime,
    required this.spec,
    required this.sport,
    required this.startTime,
    required this.status,
    required this.traineeId,
    required this.trainerId,
  });

  factory TrainingSession.fromFirestore(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    return TrainingSession(
      sessionId: document.id,
      endTime: data['endTime'] as Timestamp,
      spec: data['spec'] ?? '',
      sport: data['sport'] ?? '',
      startTime: data['startTime'] as Timestamp,
      status: data['status'] ?? '',
      traineeId: data['traineeId'] ?? '',
      trainerId: data['trainerId'] ?? '',
    );
  }
}

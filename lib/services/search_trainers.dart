import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer.dart';

class SearchTrainers {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<TrainerProfile>> searchTrainersStream({
    DateTime? startDate,
    DateTime? endDate,
    String? sport,
    String? specialization,
  }) async* {
    var query = firestore.collection('profiles').where('roleView', isEqualTo: 'trainer');
    if (sport != null) {
      query = query.where('sport', isEqualTo: sport);
    }

    final querySnapshot = await query.get();
    List<TrainerProfile> matchingTrainers = [];

    for (var trainerDoc in querySnapshot.docs) {
      final hasSpecialization = await checkSpecialization(trainerDoc, specialization);
      final isAvailable = await checkAvailability(trainerDoc, startDate, endDate);

      if (hasSpecialization && isAvailable) {
        final noConflictingSessions = await checkTrainingSessionOverlap(trainerDoc.id, startDate, endDate);
        if (noConflictingSessions) {
          matchingTrainers.add(TrainerProfile.fromFirestore(trainerDoc));
        }
      }
    }

    yield matchingTrainers;
  }

  Future<bool> checkSpecialization(DocumentSnapshot trainerDoc, String? specialization) async {
    final specializationSnapshot = await trainerDoc.reference.collection('specializations').get();
    return specializationSnapshot.docs.any((specDoc) => specDoc['name'] == specialization);
  }

  Future<bool> checkAvailability(DocumentSnapshot trainerDoc, DateTime? startDate, DateTime? endDate) async {
    final availabilitySnapshot = await trainerDoc.reference.collection('datesAvailability').get();
    return availabilitySnapshot.docs.any((doc) {
      final data = doc.data() as Map;
      final availStartTime = (data['startTime'] as Timestamp).toDate().toLocal();
      final availEndTime = (data['endTime'] as Timestamp).toDate().toLocal();
      return availStartTime != null &&
          availEndTime != null &&
          startDate != null &&
          endDate != null &&
          availStartTime.isBefore(endDate) &&
          availEndTime.isAfter(startDate);
    });
  }

  Future<bool> checkTrainingSessionOverlap(String trainerId, DateTime? startDate, DateTime? endDate) async {
    final sessionSnapshots = await firestore.collection('training_sessions')
        .where('trainerId', isEqualTo: trainerId)
        .where('status', whereIn: ['pending', 'approved'])
        .get();

    bool noOverlap = true;

    for (var sessionDoc in sessionSnapshots.docs) {
      final sessionData = sessionDoc.data() as Map;
      final sessionStartTime = (sessionData['startTime'] as Timestamp).toDate();
      final sessionEndTime = (sessionData['endTime'] as Timestamp).toDate();

      if (sessionStartTime.isBefore(endDate!) && sessionEndTime.isAfter(startDate!)) {
        noOverlap = false;
        break;
      }
    }

    return noOverlap;
  }
}

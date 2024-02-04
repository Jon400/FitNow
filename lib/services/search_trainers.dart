import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer.dart'; // Ensure this path matches your project structure

class SearchTrainers {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

    // Fetch all trainers matching the initial criteria
    final querySnapshot = await query.get();
    List<TrainerProfile> matchingTrainers = [];

    // Iterate through each trainer document
    for (var trainerDoc in querySnapshot.docs) {
      final hasSpecialization = await checkSpecialization(trainerDoc, specialization);
      if (hasSpecialization) {
        final isAvailable = await checkTimesAvailable(
            trainerDoc, startDate, endDate);
        if (isAvailable) {
          final noConflictingSessions = await checkTrainingSessionOverlap(
              trainerDoc.id, startDate, endDate);
          if (noConflictingSessions) {
            matchingTrainers.add(TrainerProfile.fromFirestore(trainerDoc));
          }
        }
      }
    }
    yield matchingTrainers;
  }

  Future<bool> checkSpecialization(DocumentSnapshot trainerDoc, String? specialization) async {
    if (specialization == null) return true; // If no specialization is specified, skip this check
    final specializationSnapshot = await trainerDoc.reference.collection('specializations').get();
    return specializationSnapshot.docs.any((specDoc) => specDoc['name'] == specialization);
  }

  Future<bool> checkTimesAvailable(DocumentSnapshot trainerDoc, DateTime? startDate, DateTime? endDate) async {
    if (startDate == null || endDate == null) return true; // Assume availability if dates are not provided

    final availabilitySnapshot = await trainerDoc.reference.collection('datesAvailability').get();
    for (var doc in availabilitySnapshot.docs) {
      final availabilityData = doc.data() as Map;
      final availabilityStartTime = availabilityData['startTime'].toDate();
      final availabilityEndTime = availabilityData['endTime'].toDate();

      // If the availability overlaps with the requested range, check for exact coverage
      if (!(endDate.isBefore(availabilityStartTime) || startDate.isAfter(availabilityEndTime))) {
        // Availability overlaps with the request; now check if it completely covers the requested range
        return true;
      }
    }

    // No availability completely covers the requested range, indicating no availability
    return false;
  }

  Future<bool> checkTrainingSessionOverlap(String trainerId, DateTime? startDate, DateTime? endDate) async {
    if (startDate == null || endDate == null) return true; // Assume availability if dates are not provided

    final sessionSnapshots = await firestore.collection('training_sessions')
        .where('trainerId', isEqualTo: trainerId)
        .where('status', whereIn: ['pending', 'approved'])
        .orderBy('startTime')
        .get();

    for (var doc in sessionSnapshots.docs) {
      final sessionData = doc.data() as Map;
      final sessionStartTime = (sessionData['startTime'] as Timestamp).toDate();
      final sessionEndTime = (sessionData['endTime'] as Timestamp).toDate();

      // If the session overlaps with the requested range, check for exact coverage
      if (!(endDate.isBefore(sessionStartTime) || startDate.isAfter(sessionEndTime))) {
        // Session overlaps with the request; now check if it completely covers the requested range
        if (startDate.isAfter(sessionStartTime) && endDate.isBefore(sessionEndTime)) {
          // The requested range is completely within a session, indicating no availability
          return false;
        }
      }
    }

    // No session completely covers the requested range, indicating availability
    return true;
  }
}
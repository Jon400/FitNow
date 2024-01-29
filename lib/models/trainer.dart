import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/profile.dart';
import 'package:flutter/material.dart';

class TrainerProfile extends Profile {
  final String logoUrl;
  final String description;
  final String sport;
  final List<String> specializations;

  TrainerProfile({
    required super.pid,
    required super.email,
    required super.roleView,
    required super.firstName,
    required super.lastName,
    required this.logoUrl,
    required this.description,
    required this.sport,
    required this.specializations,
  });

  factory TrainerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return TrainerProfile(
      pid: doc.id,
      email: data?['email'] ?? '',
      roleView: data?['roleView'] ?? '',
      firstName: data?['firstName'] ?? 'Guest',
      lastName: data?['lastName'] ?? '',
      logoUrl: data?['logoUrl'] ?? '',
      description: data?['description'] ?? '',
      sport: data?['sport'] ?? '',
      specializations: [],
    );
  }

  // fetches the trainer's specializations from the database using stream
  Stream<List<String>> getSpecializations() {
    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(pid)
        .collection('specializations')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['name'] as String).toList());
  }

  // this stream will return a list of time stamp (ranges) availability, datas and time
  // of the trainer according to the datesAvailability collection and remove
  // the duration of the training session that is already booked in
  // training_sessions collection (pending or approved)
  // use "training_sessions" collection to check if the trainer is available
  // for the time slot requested by the trainee

  Stream<List<TimeRange>> getAvailableTimeSlots(DateTime startDate, DateTime endDate) {
    // Fetch the available time slots
    var availabilityStream = FirebaseFirestore.instance
        .collection('profiles')
        .doc(pid)
        .collection('datesAvailability')
        .where('endTime', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TimeRange.fromFirestore(doc)).toList());

    // Fetch the booked time slots
    var bookedSessionsStream = FirebaseFirestore.instance
        .collection('training_sessions')
        .where('trainerId', isEqualTo: pid)
        .where('endTime', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TimeRange.fromFirestore(doc)).toList());

    return availabilityStream.asyncMap((
        List<TimeRange> availableTimeRanges) async {
      var bookedTimeRanges = await bookedSessionsStream.first;

      List<TimeRange> filteredAvailableTimeRanges = [];
      for (var availableTimeRange in availableTimeRanges) {
        var startTime = availableTimeRange.startTime;
        var endTime = availableTimeRange.endTime;

        for (var bookedTimeRange in bookedTimeRanges) {
          if (bookedTimeRange.endTime.isBefore(availableTimeRange.startTime) ||
              bookedTimeRange.startTime.isAfter(availableTimeRange.endTime)) {
            // No overlap, add the entire available time range
            filteredAvailableTimeRanges.add(availableTimeRange);
          } else {
            // Split the time range around the booked session
            if (bookedTimeRange.startTime.isAfter(startTime) &&
                bookedTimeRange.startTime.isBefore(endTime)) {
              // Add time before the booked session
              filteredAvailableTimeRanges.add(TimeRange(
                  startTime: startTime, endTime: bookedTimeRange.startTime));
            }
            if (bookedTimeRange.endTime.isAfter(startTime) &&
                bookedTimeRange.endTime.isBefore(endTime)) {
              // Add time after the booked session
              startTime = bookedTimeRange.endTime;
            }
          }
        }

        // Add remaining time slot after all booked sessions are accounted for
        if (startTime.isBefore(endTime)) {
          filteredAvailableTimeRanges.add(
              TimeRange(startTime: startTime, endTime: endTime));
        }
      }

      return filteredAvailableTimeRanges;
    });
  }
}

class TimeRange {
  final DateTime startTime;
  final DateTime endTime;

  TimeRange({
    required this.startTime,
    required this.endTime,
  });
  // getters
  DateTime get startDate => startTime;
  DateTime get endDate => endTime;

  factory TimeRange.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TimeRange(
      startTime: (data['startTime'] as Timestamp).toDate().toLocal(),
      endTime: (data['endTime'] as Timestamp).toDate().toLocal(),
    );
  }
}
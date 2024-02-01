import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../trainer_button/ActivityTime_button.dart';
import '../trainer_button/request_button.dart';
import '../trainer_button/planning_button.dart';

import '../../models/trainer.dart';
import '../../services/database.dart';

class TrainerProfileScreen extends StatefulWidget {
  @override
  _TrainerProfileScreenState createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedSport;
  List<String> specs = [];
  String? selectedSpec;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings or default values
    _firstNameController.text = '';
    _lastNameController.text = '';
    _descriptionController.text = '';
    _logoUrlController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editProfileDialog(context, currentUserId),
          ),
        ],
      ),
      body: StreamBuilder<TrainerProfile>(
        stream: DatabaseService(uid: currentUserId, roleView: '').getTrainerProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            TrainerProfile trainerData = snapshot.data!;
            // Only update controllers if the data has changed
            if (_firstNameController.text != trainerData.firstName) {
              _firstNameController.text = trainerData.firstName;
            }
            if (_lastNameController.text != trainerData.lastName) {
              _lastNameController.text = trainerData.lastName;
            }
            if (_descriptionController.text != trainerData.description) {
              _descriptionController.text = trainerData.description;
            }
            if (_logoUrlController.text != trainerData.logoUrl) {
              _logoUrlController.text = trainerData.logoUrl;
            }
            selectedSport = trainerData.sport;
            // Assuming specializations is a List<String>
            specs = trainerData.specializations;
            selectedSpec = specs.isNotEmpty ? specs.first : null;
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    CircleAvatar(
                      backgroundImage: NetworkImage(trainerData.logoUrl),
                      radius: 140,
                    ),
                    SizedBox(height: 20),
                    Text('First Name: ${trainerData.firstName}', style: TextStyle(fontSize: 16)),
                    Text('Last Name: ${trainerData.lastName}', style: TextStyle(fontSize: 16)),
                    Text('Sport: ${trainerData.sport}', style: TextStyle(fontSize: 16)),
                    Text('Specialisation: ${trainerData.specializations.join(", ")}', style: TextStyle(fontSize: 16)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Description: ${trainerData.description}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () { Navigator.push(
                        context,
                        PageRouteBuilder(pageBuilder: (_, __, ___) => planning_button()),
                      );}, // Placeholder for navigation to Planning
                      child: Text("Planning"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                        context,
                        PageRouteBuilder(pageBuilder: (_, __, ___) => request_button()),
                      );}, // Placeholder for navigation to Requests
                      child: Text("Requests"),
                    ),
                    ElevatedButton(
                      onPressed: () {Navigator.push(
                        context,
                        PageRouteBuilder(pageBuilder: (_, __, ___) => ActivityTime_button()),
                      );}, // Placeholder for navigation to Activity Time
                      child: Text("Activity Time"),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _editProfileDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _logoUrlController,
                  decoration: InputDecoration(labelText: 'Logo URL'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                updateTrainerProfile(userId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTrainerProfile(String userId) async {
    List<String> specializations = selectedSpec != null ? [selectedSpec!] : [];
    // Update the profile document using updateTrainerProfile in DatabaseService.dart
    await DatabaseService(uid: userId, roleView: '').updateTrainerProfile(
      _firstNameController.text,
      _lastNameController.text,
      _descriptionController.text,
      _logoUrlController.text,
      selectedSport!,
      specializations,
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }
}

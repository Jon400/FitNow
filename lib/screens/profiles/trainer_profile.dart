import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/trainer.dart';
import '../../services/database.dart';
import '../../models/sport.dart'; // Assuming this is the correct path for the Sport class

class TrainerProfileScreen extends StatefulWidget {
  @override
  _TrainerProfileScreenState createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedSport;
  List<String> selectedSpecs = [];
  Map<String, List<String>> specializationsBySport = {};

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = '';
    _lastNameController.text = '';
    _descriptionController.text = '';
    _logoUrlController.text = '';
    fetchSportsAndSpecializations();
  }

  void fetchSportsAndSpecializations() async {
    var sportsSnapshot = await _firestore.collection('sports').get();
    var newSpecializationsBySport = <String, List<String>>{};

    for (var sportDoc in sportsSnapshot.docs) {
      Sport sport = Sport.fromFirestore(sportDoc);
      newSpecializationsBySport[sport.name] = sport.specializations;
    }

    if (newSpecializationsBySport.isNotEmpty) {
      setState(() {
        specializationsBySport = newSpecializationsBySport;
        selectedSport = specializationsBySport.keys.first;
        selectedSpecs = specializationsBySport[selectedSport!] ?? [];
      });
    }
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
            _firstNameController.text = trainerData.firstName;
            _lastNameController.text = trainerData.lastName;
            _descriptionController.text = trainerData.description;
            _logoUrlController.text = trainerData.logoUrl;
            selectedSport = trainerData.sport;
            selectedSpecs = trainerData.specializations;

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
                    Text('Specializations: ${selectedSpecs.join(", ")}', style: TextStyle(fontSize: 16)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Description: ${trainerData.description}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {}, // Placeholder for navigation
                      child: Text("Planning"),
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Placeholder for navigation
                      child: Text("Requests"),
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Placeholder for navigation
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
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
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
                    DropdownButtonFormField<String>(
                      value: selectedSport,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSport = newValue!;
                          selectedSpecs = specializationsBySport[selectedSport] ?? [];
                        });
                      },
                      items: specializationsBySport.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    MultiSelectChip(
                      specializationsBySport[selectedSport] ?? [],
                      onSelectionChanged: (selectedList) {
                        setState(() {
                          selectedSpecs = selectedList;
                        });
                      },
                      selectedChoices: selectedSpecs,
                    ),
                  ],
                ),
              );
            },
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
    await DatabaseService(uid: userId, roleView: '').updateTrainerProfile(
      _firstNameController.text,
      _lastNameController.text,
      _descriptionController.text,
      _logoUrlController.text,
      selectedSport!,
      selectedSpecs,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>) onSelectionChanged;
  final List<String> selectedChoices;

  MultiSelectChip(this.reportList, {required this.onSelectionChanged, required this.selectedChoices});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = [];

  @override
  void initState() {
    super.initState();
    selectedChoices = widget.selectedChoices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.reportList.map((item) {
        return ChoiceChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        );
      }).toList(),
    );
  }
}

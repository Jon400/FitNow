import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
  List<String> selectedSpecs = [];
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
            specs = trainerData.specializations;
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
                      onPressed: () {}, // Placeholder for navigation to Planning
                      child: Text("Planning"),
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Placeholder for navigation to Requests
                      child: Text("Requests"),
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Placeholder for navigation to Activity Time
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
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('sports').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DropdownMenuItem> sportItems = [];
                      for (var doc in snapshot.data!.docs) {
                        var sport = doc.data() as Map<String, dynamic>;
                        sportItems.add(
                          DropdownMenuItem(
                            child: Text(sport['name']),
                            value: sport['name'],
                          ),
                        );
                      }
                      return DropdownButton(
                        items: sportItems,
                        onChanged: (value) {
                          setState(() {
                            selectedSport = value.toString();
                            selectedSpecs.clear();
                            // Retrieve and set previously selected specializations here
                            selectedSpecs.addAll(specs);
                          });
                        },
                        value: selectedSport,
                        hint: Text('Select a sport'),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('sports').where('name', isEqualTo: selectedSport).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DropdownMenuItem> specItems = [];
                      for (var doc in snapshot.data!.docs) {
                        var sport = doc.data() as Map<String, dynamic>;
                        var specializations = sport['specializations'] as List<dynamic>;
                        for (var spec in specializations) {
                          specItems.add(
                            DropdownMenuItem(
                              child: Text(spec),
                              value: spec,
                            ),
                          );
                        }
                      }
                      return Column(
                        children: [
                          DropdownButton(
                            items: specItems,
                            onChanged: (value) {
                              setState(() {
                                selectedSpecs.add(value.toString());
                              });
                            },

                            hint: Text('Select a specialization'),
                          ),
                          // Display the selected specializations
                          Text('Selected Specializations: ${selectedSpecs.join(", ")}'),
                        ],
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
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

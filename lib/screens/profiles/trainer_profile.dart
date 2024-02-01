import 'package:fit_now/screens/trainer_button/planning_button.dart';
import 'package:flutter/material.dart';

import '../trainer_button/ActivityTime_button.dart';
import '../trainer_button/request_button.dart';

class TrainerProfileScreen extends StatefulWidget {
  @override
  _TrainerProfileScreenState createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  String firstName = "John";
  String lastName = "Doe";
  String sport = "fitness";
  String specialisation = "endurance";
  String description =
      "Certified fitness trainer with 5 years of experience";
  String logo_url =
      "https://t4.ftcdn.net/jpg/03/34/51/53/360_F_334515316_2EVRXmwTnBXhkjCFGHefImZBiJi38aO1.jpg";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs existantes
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    descriptionController.text = description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Ouvrir la fenêtre modale pour l'édition du profil
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Edit Profile'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Champ de modification pour le prénom (firstName)
                          TextField(
                            controller: firstNameController,
                            onChanged: (value) {
                              setState(() {
                                firstName = value;
                              });
                            },
                            decoration: InputDecoration(labelText: 'First Name'),
                          ),
                          // Champ de modification pour le nom de famille (lastName)
                          TextField(
                            controller: lastNameController,
                            onChanged: (value) {
                              setState(() {
                                lastName = value;
                              });
                            },
                            decoration: InputDecoration(labelText: 'Last Name'),
                          ),
                          // Champ de modification pour la description (description)
                          TextField(
                            controller: descriptionController,
                            onChanged: (value) {
                              setState(() {
                                description = value;
                              });
                            },
                            decoration: InputDecoration(labelText: 'Description'),
                          ),
                          // Champ de sélection du sport (DropdownButton)
                          DropdownButton<String>(
                            value: sport,
                            items: ["fitness", "pilates", "swimming", "yoga"]
                                .map((sport) {
                              return DropdownMenuItem<String>(
                                value: sport,
                                child: Text(sport),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                sport = newValue!;
                              });
                            },
                          ),
                          // Champ de sélection de la specialisation (DropdownButton)
                          DropdownButton<String>(
                            value: specialisation,
                            items: [
                              "flexibility",
                              "strength",
                              "balance",
                              "endurance"
                            ].map((specialisation) {
                              return DropdownMenuItem<String>(
                                value: specialisation,
                                child: Text(specialisation),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                specialisation = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fermez la fenêtre modale
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Réinitialiser les contrôleurs avec les valeurs existantes
                          firstNameController.text = firstName;
                          lastNameController.text = lastName;
                          descriptionController.text = description;
                          Navigator.of(context).pop(); // Fermez la fenêtre modale sans enregistrer
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Informations du formateur
            Text('Signed In. Role: trainer'),
            Text('First Name: $firstName'),
            Text('Last Name: $lastName'),
            Text('Sport: $sport'),
            Text('Specialisation: $specialisation'),
            Text('Description: $description'),
            SizedBox(height: 1), // Espace entre les informations et l'image
            Image.network(
              logo_url,
              width: 350, // Ajustez la taille selon vos besoins
              height: 350, // Ajustez la taille selon vos besoins
            ),
            SizedBox(height: 1), // Espace entre l'image et les boutons
            // Boutons existants
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.amber),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => planning_button()),
                );
              },
              child: Text("Planning"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.amber),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(pageBuilder: (_, __, ___) => request_button()),
                    );
                  },
                  child: Text("Requests"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.amber),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(pageBuilder: (_, __, ___) => ActivityTime_button()),
                    );
                  },
                  child: Text("Activity Time"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

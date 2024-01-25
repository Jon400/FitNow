import 'package:fit_now/screens/search/request_train.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/sport.dart';
import '../../services/database.dart';
import '../../models/trainer.dart';
import '../../services/search_trainers.dart'; // Assuming TrainerProfile is the correct model

List<String> specs = [
  'Karma',
  'Hatha',
  'Vinyasa',
  // Add more specialization options here
];
List<String> sports = [
  'Yoga',
  'Pilates',
  'Meditation',
  // Add more sport options here
];

class TraineeSearchPage extends StatefulWidget {
  @override
  _TraineeSearchPageState createState() => _TraineeSearchPageState();
}

class _TraineeSearchPageState extends State<TraineeSearchPage> {
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  String selectedSport = 'Yoga';
  String selectedSpec = 'Karma';
  late Future<List<TrainerProfile>> futureTrainers;
  late Stream<List<TrainerProfile>> streamTrainer;
  late AppUser user; // Declare user variable at the class level
  late Stream<List<Sport>> streamSports;

  @override
  void initState() {
    super.initState();
    // // now
    selectedSport = sports.first;
    selectedSpec = specs.first;
    user = Provider.of<AppUser?>(context, listen: false)!; // Initialize user
    streamTrainer = Stream<List<TrainerProfile>>.empty(); // Initialize streamTrainer
    streamSports = Stream<List<Sport>>.empty(); // Initialize streamSports
    getSports(user);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Initialize futureTrainers here
      searchTrainers(user);
    });
  }

  Future<Stream<List<Sport>>> getSports(AppUser user) async{
    // Initialize DatabaseService with user's UID
    final DatabaseService databaseService = DatabaseService(
      uid: user.uid,
      roleView: 'trainee',
    );
    // Call the sports getter in DatabaseService
    final sports = await databaseService.sports;
    setState(() {
      streamSports = sports;
    });
    return sports;
  }

  Future<Stream<List<TrainerProfile>>> searchTrainers(AppUser user) async {
    // Initialize SearchTrainers instance
    final searchTrainers = SearchTrainers();

    // Call the search method in SearchTrainers
    final trainers = searchTrainers.searchTrainersStream(
      startDate: startDate == null || startTime == null
          ? null
          : DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startTime!.hour,
        startTime!.minute,
      ),
      endDate: endDate == null || endTime == null
          ? null
          : DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        endTime!.hour,
        endTime!.minute,
      ),
      sport: selectedSport.isNotEmpty ? selectedSport : null,
      specialization: selectedSpec.isNotEmpty ? selectedSpec : null,
    );

    setState(() {
      streamTrainer = trainers;
    });

    return trainers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Training Sessions'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(startDate == null ? 'Pick start date and time' : "${startDate!.toLocal()} at $startTime"),
            trailing: Icon(Icons.calendar_today),
            onTap: pickStartDateTime,
          ),
          ListTile(
            title: Text(endDate == null ? 'Pick end date and time' : "${endDate!.toLocal()} at $endTime"),
            trailing: Icon(Icons.calendar_today),
            onTap: pickEndDateTime,
          ),
          StreamBuilder<List<Sport>>(
            stream: streamSports,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DropdownButton<String>(
                  items: [],
                  onChanged: null,
                  hint: Text("Loading sports..."),
                );
              }
              if (snapshot.hasError) {
                return DropdownButton<String>(
                  items: [],
                  onChanged: null,
                  hint: Text("Error: ${snapshot.error}"),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return DropdownButton<String>(
                  items: [],
                  onChanged: null,
                  hint: Text("No sports available"),
                );
              }
              List<Sport> sportsList = snapshot.data!;
              return DropdownButton<String>(
                value: selectedSport,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSport = newValue!;
                    specs = sportsList.firstWhere((s) => s.name == selectedSport).specializations;
                    selectedSpec = specs.isNotEmpty ? specs.first : 'DefaultSpecValue'; // Update this line
                    searchTrainers(user);
                  });
                },
                items: sportsList.map<DropdownMenuItem<String>>((Sport sport) {
                  return DropdownMenuItem<String>(
                    value: sport.name,
                    child: Text(sport.name),
                  );
                }).toList(),
              );
            },
          ),
          DropdownButton<String>(
            value: selectedSpec, // Make sure selectedSpec contains a valid value from specs
            onChanged: (String? newValue) {
              setState(() {
                selectedSpec = newValue!;
                searchTrainers(user);
              });
            },
            items: specs.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value, // Ensure that each value is unique
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<List<TrainerProfile>>(
              stream: streamTrainer,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No trainers found'));
                }

                List<TrainerProfile> trainers = snapshot.data!;

                return ListView.builder(
                  itemCount: trainers.length,
                  itemBuilder: (context, index) {
                    final trainer = trainers[index];
                    return ListTile(
                      title: Text(trainer.firstName + ' ' + trainer.lastName),
                      subtitle: StreamBuilder<List<String>>(
                        stream: trainer.getSpecializations(),
                        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                          print("Snapshot data: ${snapshot.data}");
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text('Loading specializations...');
                          } else if (snapshot.hasError) {
                            print("Error: ${snapshot.error}");
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No specializations');
                          } else {
                            return Text('${trainer.sport} - ${snapshot.data!.join(', ')}');
                          }
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.info),
                            color: Colors.red,
                            onPressed: () {
                              // Handle the information button click here
                            },
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the RequestTrainingScreen and pass the trainer data
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider<TrainerProfile>.value(
                                    value: trainer, // Assuming 'trainer' is a TrainerProfile instance
                                    child: RequestTrainingScreen(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            child: Text('Request'),
                          ),
                        ],
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  void pickStartDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: startTime ?? TimeOfDay.now(),
      );
      setState(() {
        startDate = pickedDate;
        startTime = pickedTime;
        searchTrainers(user); // Pass the user to the search method
      });
    }
  }

  void pickEndDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: endTime ?? TimeOfDay.now(),
      );
      setState(() {
        endDate = pickedDate;
        endTime = pickedTime;
        searchTrainers(user); // Pass the user to the search method
      });
    }
  }
}
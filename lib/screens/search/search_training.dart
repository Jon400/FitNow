import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../services/database.dart';
import '../../models/trainer.dart'; // Assuming TrainerProfile is the correct model

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

  @override
  void initState() {
    super.initState();
    user = Provider.of<AppUser?>(context, listen: false)!; // Initialize user
    streamTrainer = Stream<List<TrainerProfile>>.empty(); // Initialize streamTrainer
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Initialize futureTrainers here
      searchTrainers(user);
    });
  }

  Future<Stream<List<TrainerProfile>>> searchTrainers(AppUser user) async {
    // Initialize DatabaseService with user's UID
    final DatabaseService databaseService = DatabaseService(
      uid: user.uid,
      roleView: 'trainee',
    );

    // Call the search method in DatabaseService
    final trainers = await databaseService.searchTrainersStream(
      // combine start date and start tine into a single DateTime object
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
          DropdownButton<String>(
            value: selectedSport,
            onChanged: (String? newValue) {
              setState(() {
                selectedSport = newValue!;
                searchTrainers(user);
              });
            },
            items: sports.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: selectedSpec,
            onChanged: (String? newValue) {
              setState(() {
                selectedSpec = newValue!;
                searchTrainers(user);
              });
            },
            items: specs.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
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
                      title: Text(trainer.firstName),
                      subtitle: Text('${trainer.sport} - ${trainer.specializations.join(', ')}'),
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

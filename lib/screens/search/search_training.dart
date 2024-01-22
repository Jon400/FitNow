import 'package:flutter/material.dart';

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

  final List<String> sports = ['Yoga', 'Fitness', 'Pilates', 'Swimming'];
  final List<String> specs = ['Karma', 'Aerial', 'Hatha', 'Vinyasa'];

  final List<Trainer> trainers = [
    Trainer(name: "John Doe", sport: "Football", specialization: "Offense", dateTime: DateTime.now().add(Duration(days: 1))),
    Trainer(name: "Jane Smith", sport: "Tennis", specialization: "Strategy", dateTime: DateTime.now().add(Duration(days: 2))),
    // Add more trainers
  ];

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
            child: ListView.builder(
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final trainer = trainers[index];
                if (_matchesSearchCriteria(trainer)) {
                  return ListTile(
                    title: Text(trainer.name),
                    subtitle: Text('${trainer.sport} - ${trainer.specialization}'),
                    trailing: Text('${trainer.dateTime}'),
                  );
                } else {
                  return Container();
                }
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
      });
    }
  }

  bool _matchesSearchCriteria(Trainer trainer) {
    // Start and end DateTime combining date and time
    DateTime? startDateTime = startDate != null && startTime != null
        ? DateTime(startDate!.year, startDate!.month, startDate!.day, startTime!.hour, startTime!.minute)
        : null;
    DateTime? endDateTime = endDate != null && endTime != null
        ? DateTime(endDate!.year, endDate!.month, endDate!.day, endTime!.hour, endTime!.minute)
        : null;

    if (startDateTime != null && trainer.dateTime.isBefore(startDateTime)) {
      return false;
    }
    if (endDateTime != null && trainer.dateTime.isAfter(endDateTime)) {
      return false;
    }
    if (trainer.sport != selectedSport) {
      return false;
    }
    if (trainer.specialization != selectedSpec) {
      return false;
    }
    return true;
  }
}

class Trainer {
  String name;
  DateTime dateTime;
  String sport;
  String specialization;

  Trainer({required this.name, required this.dateTime, required this.sport, required this.specialization});
}
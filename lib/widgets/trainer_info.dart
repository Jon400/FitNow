import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trainer.dart'; // Ensure this path is correct

class TrainerInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accessing TrainerProfile from Provider
    TrainerProfile trainerProfile = Provider.of<TrainerProfile>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Center for logo and close button
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(trainerProfile.logoUrl),
                radius: 60,
              ),
              SizedBox(height: 20),
              // Align left for text details
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                  children: [
                    Text('First Name: ${trainerProfile.firstName}', style: TextStyle(fontSize: 16)),
                    Text('Last Name: ${trainerProfile.lastName}', style: TextStyle(fontSize: 16)),
                    Text('Sport: ${trainerProfile.sport}', style: TextStyle(fontSize: 16)),
                    _buildSpecializationsSection(context, trainerProfile),
                    Text('Description: ${trainerProfile.description}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
}

  Widget _buildSpecializationsSection(BuildContext context, TrainerProfile trainerProfile) {
    return StreamBuilder<List<String>>(
      stream: trainerProfile.getSpecializations(), // This method must be defined in your TrainerProfile model
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error loading specializations");
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<String> specializations = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the cross axis
                children: [
                  // please fix this so the specializations are displayed in a same line
                  Text('Specializations: ${specializations.join(', ')}', style: TextStyle(fontSize: 16)),
                ],
              );
            } else {
              return Text('No specializations available', style: TextStyle(fontSize: 16));
            }
        }
      },
    );
  }
}
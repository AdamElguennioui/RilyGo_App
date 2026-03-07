import 'package:flutter/material.dart';
import '../models/mission.dart';

class MissionStatusScreen extends StatelessWidget {
  final Mission mission;
  MissionStatusScreen({required this.mission});

  @override
  Widget build(BuildContext context) {
    final statuses = ["Créée", "Assignée", "En cours", "Terminée"];
    return Scaffold(
      appBar: AppBar(title: Text("Suivi mission")),
      body: ListView.builder(
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isActive = mission.status == status;
          return ListTile(
            leading: Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked),
            title: Text(status),
          );
        },
      ),
    );
  }
}

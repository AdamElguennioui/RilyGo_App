import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';

class AgentMissionDetail extends StatelessWidget {
  final Mission mission;
  final missionService = MissionService();

  AgentMissionDetail({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détail mission")),
      body: Column(
        children: [
          Text("Catégorie: ${mission.category}"),
          Text("Adresse: ${mission.address}"),
          Text("Note: ${mission.note}"),
          ElevatedButton(
            onPressed: () {
              missionService.updateMissionStatus(mission, "En cours");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mission démarrée")));
            },
            child: Text("Commencer"),
          )
        ],
      ),
    );
  }
}

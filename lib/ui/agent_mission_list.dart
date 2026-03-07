import 'package:flutter/material.dart';
import '../services/mission_service.dart';
import '../models/mission.dart';

class AgentMissionList extends StatelessWidget {
  final missionService = MissionService();

  @override
  Widget build(BuildContext context) {
    final missions = missionService.getMissions();
    return Scaffold(
      appBar: AppBar(title: Text("Missions Agent")),
      body: ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return ListTile(
            title: Text(mission.category),
            subtitle: Text(mission.address),
            onTap: () => Navigator.pushNamed(context, "/missionDetail", arguments: mission),
          );
        },
      ),
    );
  }
}

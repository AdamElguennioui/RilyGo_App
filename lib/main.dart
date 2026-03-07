import 'package:flutter/material.dart';
import 'models/mission.dart';
import 'ui/login_screen.dart';
import 'ui/create_mission_screen.dart';
import 'ui/mission_status_screen.dart';
import 'ui/agent_mission_list.dart';
import 'ui/agent_mission_detail.dart';

void main() {
  runApp(RilyApp());
}

class RilyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rily App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/createMission': (context) => CreateMissionScreen(),
        '/agentMissions': (context) => AgentMissionList(),
        '/missionStatus': (context) {
          final mission = ModalRoute.of(context)!.settings.arguments as Mission;
          return MissionStatusScreen(mission: mission);
        },
        '/missionDetail': (context) {
          final mission = ModalRoute.of(context)!.settings.arguments as Mission;
          return AgentMissionDetail(mission: mission);
        },
      },
    );
  }
}

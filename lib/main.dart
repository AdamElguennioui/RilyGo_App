import 'package:flutter/material.dart';
import 'models/mission.dart';
import 'ui/login_screen.dart';
import 'ui/create_mission_screen.dart';
import 'ui/mission_status_screen.dart';
import 'ui/agent_mission_list.dart';
import 'ui/agent_mission_detail.dart';
import 'ui/client_home_screen.dart';
import 'ui/agent_home_screen.dart';

void main() {
  runApp(const RilyApp());
}

class RilyApp extends StatelessWidget {
  const RilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rily App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/clientHome': (context) => const ClientHomeScreen(),
        '/agentHome': (context) => const AgentHomeScreen(),
        '/createMission': (context) => const CreateMissionScreen(),
        '/agentMissions': (context) => const AgentMissionList(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/missionStatus') {
          final mission = settings.arguments as Mission;
          return MaterialPageRoute(
            builder: (context) => MissionStatusScreen(mission: mission),
          );
        }

        if (settings.name == '/missionDetail') {
          final mission = settings.arguments as Mission;
          return MaterialPageRoute(
            builder: (context) => AgentMissionDetail(mission: mission),
          );
        }

        return null;
      },
    );
  }
}
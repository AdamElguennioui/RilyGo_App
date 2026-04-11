import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/mission.dart';
import 'services/connectivity_service.dart';
import 'ui/login_screen.dart';
import 'ui/create_mission_screen.dart';
import 'ui/mission_status_screen.dart';
import 'ui/agent_mission_list.dart';
import 'ui/agent_mission_detail.dart';
import 'ui/client_home_screen.dart';
import 'ui/agent_home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barre système transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: RilyColors.bg,
    ),
  );

  // Init connectivity (prêt pour brancher connectivity_plus)
  await ConnectivityService().init();

  runApp(const RilyApp());
}

class RilyApp extends StatelessWidget {
  const RilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rily',
      debugShowCheckedModeBanner: false,
      theme: RilyTheme.theme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/clientHome': (_) => const ClientHomeScreen(),
        '/agentHome': (_) => const AgentHomeScreen(),
        '/createMission': (_) => const CreateMissionScreen(),
        '/agentMissions': (_) => const AgentMissionList(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/missionStatus':
            final mission = settings.arguments as Mission;
            return _slide(MissionStatusScreen(mission: mission));

          case '/missionDetail':
            final mission = settings.arguments as Mission;
            return _slide(AgentMissionDetail(mission: mission));

          default:
            return null;
        }
      },
    );
  }

  PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
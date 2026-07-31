import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'data/local/local_storage_service.dart';
import 'models/mission.dart';
import 'services/connectivity_service.dart';
import 'ui/login_screen.dart';
import 'ui/create_mission_screen.dart';
import 'ui/mission_status_screen.dart';
import 'ui/agent_mission_list.dart';
import 'ui/agent_mission_detail.dart';
import 'ui/client_home_screen.dart';
import 'ui/agent_home_screen.dart';
import 'ui/profile_screen.dart';
import 'ui/agent_profile_screen.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: RilyColors.bg,
      ),
    );

    // Initialise local storage before any service reads from it.
    await LocalStorageService().init();
    await ConnectivityService().init();

    runApp(const RilyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Une erreur est survenue au démarrage. Veuillez réessayer plus tard.\n($e)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),
    ));
  }
}

class RilyApp extends StatelessWidget {
  const RilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RileyQueue',
      debugShowCheckedModeBanner: false,
      theme: RilyTheme.theme,
      initialRoute: '/login',

      // ── Responsive web wrapper ────────────────────────────────────────────
      // On wide screens the app is centered in a 520-px column; the
      // surrounding area uses the app background colour.
      // Dialogs, bottom-sheets and snack-bars are all rendered inside the
      // Navigator overlay which lives within this constraint — they centre
      // correctly at any viewport width.
      builder: (context, child) => ColoredBox(
        color: RilyColors.bg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child!,
          ),
        ),
      ),

      routes: {
        '/login':         (_) => const LoginScreen(),
        '/clientHome':    (_) => const ClientHomeScreen(),
        '/agentHome':     (_) => const AgentHomeScreen(),
        '/createMission': (_) => const CreateMissionScreen(),
        '/agentMissions': (_) => const AgentMissionList(),
        '/profile':       (_) => const ProfileScreen(),
        '/agentProfile':  (_) => const AgentProfileScreen(),
      },

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/missionStatus':
            return _slide(MissionStatusScreen(
                mission: settings.arguments as Mission));
          case '/missionDetail':
            return _slide(AgentMissionDetail(
                mission: settings.arguments as Mission));
          default:
            return null;
        }
      },
    );
  }

  PageRouteBuilder<dynamic> _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (ctx, animation, secondaryAnimation) => page,
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

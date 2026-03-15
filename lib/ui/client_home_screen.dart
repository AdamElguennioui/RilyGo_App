import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final AuthService authService = AuthService();
  final MissionService missionService = MissionService();

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accueil Client')),
        body: const Center(
          child: Text('Aucun utilisateur connecté.'),
        ),
      );
    }

    if (user.role != UserRole.client) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accueil Client')),
        body: const Center(
          child: Text('Accès réservé aux clients.'),
        ),
      );
    }

    final clientMissions = missionService.getClientMissions(user.id);

    return Scaffold(
      appBar: AppBar(
  title: const Text('Accueil Client'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await authService.logout();

        if (!context.mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      },
    ),
  ],
),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/createMission');
                  setState(() {});
                },
                child: const Text('Créer une mission'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mes missions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (clientMissions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune mission créée pour le moment.'),
                ),
              )
            else
              ...clientMissions.map(
                (mission) => Card(
                  child: ListTile(
                    title: Text(mission.category),
                    subtitle: Text(
                      '${mission.address}\nStatut: ${_statusLabel(mission.status)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/missionStatus',
                        arguments: mission,
                      ).then((_) {
                        setState(() {});
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(MissionStatus status) {
    switch (status) {
      case MissionStatus.created:
        return 'Créée';
      case MissionStatus.accepted:
        return 'Assignée';
      case MissionStatus.onTheWay:
        return 'En route';
      case MissionStatus.inProgress:
        return 'En cours';
      case MissionStatus.completed:
        return 'Terminée';
    }
  }
}
import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';

class AgentMissionList extends StatefulWidget {
  const AgentMissionList({super.key});

  @override
  State<AgentMissionList> createState() => _AgentMissionListState();
}

class _AgentMissionListState extends State<AgentMissionList> {
  final MissionService missionService = MissionService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Missions Agent')),
        body: const Center(
          child: Text('Aucun utilisateur connecté.'),
        ),
      );
    }

    if (user.role != UserRole.agent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Missions Agent')),
        body: const Center(
          child: Text('Accès réservé aux agents.'),
        ),
      );
    }

    final availableMissions = missionService.getAvailableMissions();
    final assignedMissions = missionService.getAgentMissions(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions Agent'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Missions disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (availableMissions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune mission disponible pour le moment.'),
                ),
              )
            else
              ...availableMissions.map(
                (mission) => Card(
                  child: ListTile(
                    title: Text(mission.category),
                    subtitle: Text(
                      '${mission.address}\nCréneau: ${mission.timeSlot}',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () {
                        missionService.acceptMission(mission.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mission acceptée.'),
                          ),
                        );
                      },
                      child: const Text('Accepter'),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/missionDetail',
                        arguments: mission,
                      ).then((_) {
                        setState(() {});
                      });
                    },
                  ),
                ),
              ),

            const SizedBox(height: 24),

            const Text(
              'Mes missions assignées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (assignedMissions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune mission assignée.'),
                ),
              )
            else
              ...assignedMissions.map(
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
                        '/missionDetail',
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
        return 'Acceptée';
      case MissionStatus.onTheWay:
        return 'En route';
      case MissionStatus.inProgress:
        return 'En cours';
      case MissionStatus.completed:
        return 'Terminée';
    }
  }
}
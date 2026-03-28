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
                fontSize: 20,
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
                (mission) => _buildMissionCard(
                  mission: mission,
                  isAvailable: true,
                ),
              ),

            const SizedBox(height: 24),

            const Text(
              'Mes missions assignées',
              style: TextStyle(
                fontSize: 20,
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
                (mission) => _buildMissionCard(
                  mission: mission,
                  isAvailable: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard({
    required Mission mission,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/missionDetail',
            arguments: mission,
          ).then((_) {
            setState(() {});
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      mission.category,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isExpress(mission))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Express',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text('📍 ${mission.address}'),
              const SizedBox(height: 6),
              Text('🕒 ${mission.timeSlot}'),
              const SizedBox(height: 6),
              Text('📌 Statut: ${_statusLabel(mission.status)}'),
              const SizedBox(height: 6),
              Text('💰 Prix: ${_missionPrice(mission)} MAD'),
              if (mission.note.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '📝 ${mission.note}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/missionDetail',
                          arguments: mission,
                        ).then((_) {
                          setState(() {});
                        });
                      },
                      child: const Text('Voir détail'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isAvailable)
                    Expanded(
                      child: ElevatedButton(
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
                    ),
                ],
              ),
            ],
          ),
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
       case MissionStatus.cancelled:
        return 'Annulée';
    }
  }

  bool _isExpress(Mission mission) {
    try {
      return (mission as dynamic).isExpress == true;
    } catch (_) {
      return false;
    }
  }

  String _missionPrice(Mission mission) {
    try {
      final price = (mission as dynamic).price;
      return price.toString();
    } catch (_) {
      return '--';
    }
  }
}
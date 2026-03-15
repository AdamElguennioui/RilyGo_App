import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';

class MissionStatusScreen extends StatefulWidget {
  final Mission mission;

  const MissionStatusScreen({super.key, required this.mission});

  @override
  State<MissionStatusScreen> createState() => _MissionStatusScreenState();
}

class _MissionStatusScreenState extends State<MissionStatusScreen> {
  final MissionService missionService = MissionService();

  static const List<MissionStatus> timeline = [
    MissionStatus.created,
    MissionStatus.accepted,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completed,
  ];

  static const Map<MissionStatus, String> statusLabels = {
    MissionStatus.created: 'Mission créée',
    MissionStatus.accepted: 'Agent assigné',
    MissionStatus.onTheWay: 'Agent en route',
    MissionStatus.inProgress: 'Mission en cours',
    MissionStatus.completed: 'Mission terminée',
  };

  Mission get currentMission {
    return missionService.missions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => widget.mission,
    );
  }

  int _currentIndex(Mission mission) {
    return timeline.indexOf(mission.status);
  }

  @override
  Widget build(BuildContext context) {
    final mission = currentMission;
    final currentIndex = _currentIndex(mission);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de mission'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catégorie: ${mission.category}'),
                    const SizedBox(height: 8),
                    Text('Adresse: ${mission.address}'),
                    const SizedBox(height: 8),
                    Text('Créneau: ${mission.timeSlot}'),
                    const SizedBox(height: 8),
                    Text('Note: ${mission.note}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Timeline de la mission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(timeline.length, (index) {
              final status = timeline[index];
              final label = statusLabels[status]!;
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;

              return Card(
                child: ListTile(
                  leading: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(label),
                  subtitle: isCurrent ? const Text('Statut actuel') : null,
                ),
              );
            }),
            const SizedBox(height: 16),
            if (mission.proof != null) ...[
              const Text(
                'Preuve de mission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Image: ${mission.proof!.imagePath ?? 'Aucune image'}'),
                      const SizedBox(height: 8),
                      Text('Commentaire: ${mission.proof!.comment ?? 'Aucun commentaire'}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
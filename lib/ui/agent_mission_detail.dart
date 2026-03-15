import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/mission_service.dart';

class AgentMissionDetail extends StatefulWidget {
  final Mission mission;

  const AgentMissionDetail({super.key, required this.mission});

  @override
  State<AgentMissionDetail> createState() => _AgentMissionDetailState();
}

class _AgentMissionDetailState extends State<AgentMissionDetail> {
  final MissionService missionService = MissionService();
  final TextEditingController proofCommentController = TextEditingController();

  @override
  void dispose() {
    proofCommentController.dispose();
    super.dispose();
  }

  Mission get currentMission {
    return missionService.missions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => widget.mission,
    );
  }

  void _updateStatus(MissionStatus status, String message) {
    missionService.updateMissionStatus(currentMission.id, status);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addProof() {
    final comment = proofCommentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de saisir un commentaire de preuve.'),
        ),
      );
      return;
    }

    missionService.addProof(
      missionId: currentMission.id,
      imagePath: 'assets/proof_placeholder.jpg',
      comment: comment,
    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preuve ajoutée avec succès.'),
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

  @override
  Widget build(BuildContext context) {
    final mission = currentMission;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail mission'),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 8),
            Text('Statut: ${_statusLabel(mission.status)}'),
            const SizedBox(height: 24),

            const Text(
              'Actions mission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mission.status == MissionStatus.accepted
                    ? () => _updateStatus(
                          MissionStatus.onTheWay,
                          'Mission mise en route.',
                        )
                    : null,
                child: const Text('Mettre en route'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mission.status == MissionStatus.onTheWay
                    ? () => _updateStatus(
                          MissionStatus.inProgress,
                          'Mission en cours.',
                        )
                    : null,
                child: const Text('Commencer mission'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mission.status == MissionStatus.inProgress
                    ? () => _updateStatus(
                          MissionStatus.completed,
                          'Mission terminée.',
                        )
                    : null,
                child: const Text('Terminer mission'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Ajouter une preuve',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: proofCommentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Commentaire preuve',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addProof,
                child: const Text('Uploader preuve'),
              ),
            ),

            const SizedBox(height: 24),

            if (mission.proof != null) ...[
              const Text(
                'Preuve actuelle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Image: ${mission.proof!.imagePath ?? 'Aucune image'}'),
              const SizedBox(height: 8),
              Text('Commentaire: ${mission.proof!.comment ?? 'Aucun commentaire'}'),
            ],
          ],
        ),
      ),
    );
  }
}
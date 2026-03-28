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

  Future<void> _updateStatus(MissionStatus status, String message) async {
    try {
      await missionService.updateMissionStatus(currentMission.id, status);

      if (!mounted) return;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addProof() async {
    final comment = proofCommentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de saisir un commentaire de preuve.'),
        ),
      );
      return;
    }

    try {
      await missionService.addProof(
        missionId: currentMission.id,
        imagePath: 'assets/proof_placeholder.jpg',
        comment: comment,
      );

      proofCommentController.clear();

      if (!mounted) return;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preuve ajoutée avec succès.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _cancelMission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annuler la mission'),
          content: const Text(
            'Voulez-vous vraiment annuler cette mission ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await missionService.cancelMission(currentMission.id);

      if (!mounted) return;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission annulée avec succès.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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

  Color _statusColor(MissionStatus status) {
    switch (status) {
      case MissionStatus.created:
        return Colors.grey;
      case MissionStatus.accepted:
        return Colors.blue;
      case MissionStatus.onTheWay:
        return Colors.orange;
      case MissionStatus.inProgress:
        return Colors.deepPurple;
      case MissionStatus.completed:
        return Colors.green;
      case MissionStatus.cancelled:
        return Colors.red;
    }
  }

  bool _canAddProof(Mission mission) {
    return mission.status == MissionStatus.inProgress ||
        mission.status == MissionStatus.completed;
  }

  bool _canCancelMission(Mission mission) {
    return mission.status != MissionStatus.completed &&
        mission.status != MissionStatus.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final mission = currentMission;
    final statusColor = _statusColor(mission.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail mission'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (mission.isExpress)
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
                    const SizedBox(height: 14),
                    Text('📍 Adresse: ${mission.address}'),
                    const SizedBox(height: 8),
                    Text('🕒 Créneau: ${mission.timeSlot}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('📌 Statut: '),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(mission.status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💰 Prix de base: ${mission.basePrice.toStringAsFixed(2)} MAD',
                    ),
                    const SizedBox(height: 8),
                    Text('⚡ Express: ${mission.isExpress ? "Oui" : "Non"}'),
                    const SizedBox(height: 8),
                    Text(
                      '💵 Prix total: ${mission.totalPrice.toStringAsFixed(2)} MAD',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📝 Note: ${mission.note.isEmpty ? "Aucune note" : mission.note}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Progression mission',
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
              enabled: _canAddProof(mission),
              decoration: const InputDecoration(
                labelText: 'Commentaire preuve',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canAddProof(mission) ? _addProof : null,
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Image: ${mission.proof!.imagePath}'),
                      const SizedBox(height: 8),
                      Text(
                        'Commentaire: ${mission.proof!.comment ?? 'Aucun commentaire'}',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _canCancelMission(mission) ? _cancelMission : null,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Annuler mission'),
              ),
            ),

            const SizedBox(height: 16),

            if (mission.status == MissionStatus.completed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.25),
                  ),
                ),
                child: const Text(
                  'Mission terminée. Étape suivante : brancher le rating côté client.',
                ),
              ),

            if (mission.status == MissionStatus.cancelled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.25),
                  ),
                ),
                child: const Text(
                  'Cette mission est annulée. Aucune autre action n’est disponible.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
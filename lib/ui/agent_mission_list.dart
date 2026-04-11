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
  final MissionService _missionService = MissionService();
  final AuthService _authService = AuthService();

  // Garde l'id de la mission en cours d'acceptation (pour désactiver son bouton)
  String? _acceptingMissionId;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Missions Agent')),
        body: const Center(child: Text('Aucun utilisateur connecté.')),
      );
    }

    if (user.role != UserRole.agent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Missions Agent')),
        body: const Center(child: Text('Accès réservé aux agents.')),
      );
    }

    final availableMissions = _missionService.getAvailableMissions();
    final assignedMissions = _missionService.getAgentMissions(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Missions Agent')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Disponibles ──
            const Text(
              'Missions disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                (m) => _MissionCard(
                  mission: m,
                  showAcceptButton: true,
                  isAccepting: _acceptingMissionId == m.id,
                  onAccept: () => _acceptMission(m.id),
                  onDetail: () => _goToDetail(m),
                ),
              ),

            const SizedBox(height: 24),

            // ── Assignées ──
            const Text(
              'Mes missions assignées',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                (m) => _MissionCard(
                  mission: m,
                  showAcceptButton: false,
                  isAccepting: false,
                  onAccept: () {},
                  onDetail: () => _goToDetail(m),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptMission(String missionId) async {
    if (_acceptingMissionId != null) return; // déjà une acceptation en cours

    setState(() => _acceptingMissionId = missionId);

    try {
      await _missionService.acceptMission(missionId);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission acceptée !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _acceptingMissionId = null);
    }
  }

  void _goToDetail(Mission mission) {
    Navigator.pushNamed(
      context,
      '/missionDetail',
      arguments: mission,
    ).then((_) => setState(() {}));
  }
}

// ─── Card mission réutilisable ───────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final Mission mission;
  final bool showAcceptButton;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onDetail;

  const _MissionCard({
    required this.mission,
    required this.showAcceptButton,
    required this.isAccepting,
    required this.onAccept,
    required this.onDetail,
  });

  String _statusLabel(MissionStatus s) {
    switch (s) {
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

  Color _statusColor(MissionStatus s) {
    switch (s) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(mission.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onDetail,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catégorie + badge express
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      mission.category,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (mission.isExpress)
                    _badge('⚡ Express', Colors.orange),
                ],
              ),
              const SizedBox(height: 10),

              Text('📍 ${mission.address}'),
              const SizedBox(height: 4),
              Text('🕒 ${mission.timeSlot}'),
              const SizedBox(height: 4),

              Row(
                children: [
                  const Text('📌 '),
                  _badge(_statusLabel(mission.status), statusColor),
                ],
              ),
              const SizedBox(height: 4),

              // FIX : on utilise directement totalPrice (le bug "double cast" est corrigé)
              Text(
                  '💰 ${mission.totalPrice.toStringAsFixed(0)} MAD'),

              if (mission.note.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '📝 ${mission.note}',
                  style: const TextStyle(color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDetail,
                      child: const Text('Voir détail'),
                    ),
                  ),
                  if (showAcceptButton) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isAccepting ? null : onAccept,
                        child: isAccepting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text('Accepter'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
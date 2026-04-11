import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';

class MissionStatusScreen extends StatefulWidget {
  final Mission mission;

  const MissionStatusScreen({super.key, required this.mission});

  @override
  State<MissionStatusScreen> createState() => _MissionStatusScreenState();
}

class _MissionStatusScreenState extends State<MissionStatusScreen> {
  final MissionService _missionService = MissionService();
  final AuthService _authService = AuthService();

  bool _isCancelling = false;
  bool _isRating = false;

  // Rating
  int _selectedScore = 0;
  final TextEditingController _ratingCommentController =
      TextEditingController();

  static const List<MissionStatus> _timeline = [
    MissionStatus.created,
    MissionStatus.accepted,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completed,
  ];

  static const Map<MissionStatus, String> _statusLabels = {
    MissionStatus.created: 'Mission créée',
    MissionStatus.accepted: 'Agent assigné',
    MissionStatus.onTheWay: 'Agent en route',
    MissionStatus.inProgress: 'Mission en cours',
    MissionStatus.completed: 'Mission terminée',
    MissionStatus.cancelled: 'Mission annulée',
  };

  @override
  void dispose() {
    _ratingCommentController.dispose();
    super.dispose();
  }

  Mission get _currentMission {
    return _missionService.missions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => widget.mission,
    );
  }

  // ─── Annulation ─────────────────────────────────────────────────────────────

  Future<void> _cancelMission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la mission'),
        content:
            const Text('Voulez-vous vraiment annuler cette mission ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      await _missionService.cancelMission(_currentMission.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission annulée.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  // ─── Rating ──────────────────────────────────────────────────────────────────

  Future<void> _submitRating() async {
    if (_selectedScore == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de sélectionner une note.')),
      );
      return;
    }

    setState(() => _isRating = true);

    try {
      await _missionService.rateMission(
        missionId: _currentMission.id,
        score: _selectedScore,
        comment: _ratingCommentController.text.trim().isEmpty
            ? null
            : _ratingCommentController.text.trim(),
      );
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre avis !')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isRating = false);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  int _currentIndex(Mission mission) {
    if (mission.status == MissionStatus.cancelled) return -1;
    return _timeline.indexOf(mission.status);
  }

  @override
  Widget build(BuildContext context) {
    final mission = _currentMission;
    final currentIndex = _currentIndex(mission);
    final isCancelled = mission.status == MissionStatus.cancelled;
    final canCancel = _missionService.canCancel(mission);
    final canRate = _missionService.canRate(mission.id);
    final alreadyRated = mission.ratingScore != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de mission')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Infos mission ──
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mission.category,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (mission.isExpress)
                          _badge('⚡ Express', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('📍 ${mission.address}'),
                    const SizedBox(height: 6),
                    Text('🕒 ${mission.timeSlot}'),
                    const SizedBox(height: 6),
                    Text(
                        '💰 ${mission.totalPrice.toStringAsFixed(0)} MAD'),
                    if (mission.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('📝 ${mission.note}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Statut annulée ──
            if (isCancelled)
              _alertBox(
                color: Colors.red,
                icon: Icons.cancel_outlined,
                message: 'Cette mission a été annulée.',
              ),

            // ── Timeline ──
            if (!isCancelled) ...[
              const Text(
                'Avancement',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(_timeline.length, (index) {
                final status = _timeline[index];
                final label = _statusLabels[status]!;
                final isDone = index <= currentIndex;
                final isCurrent = index == currentIndex;

                return _timelineStep(
                  label: label,
                  isDone: isDone,
                  isCurrent: isCurrent,
                );
              }),
            ],

            const SizedBox(height: 20),

            // ── Preuve ──
            if (mission.proof != null) ...[
              const Text(
                'Preuve de mission',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '🖼️ ${mission.proof!.imagePath ?? 'Aucune image'}'),
                      const SizedBox(height: 6),
                      Text(
                          '💬 ${mission.proof!.comment ?? 'Aucun commentaire'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Rating (client, mission completed, pas encore notée) ──
            if (canRate) ...[
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Évaluer la mission',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _StarRating(
                selected: _selectedScore,
                onSelect: (score) =>
                    setState(() => _selectedScore = score),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ratingCommentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRating ? null : _submitRating,
                  child: Text(
                      _isRating ? 'Envoi...' : 'Envoyer mon avis'),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Rating déjà soumis ──
            if (alreadyRated) ...[
              const Divider(),
              const SizedBox(height: 12),
              _alertBox(
                color: Colors.green,
                icon: Icons.star,
                message:
                    'Vous avez noté cette mission ${mission.ratingScore}/5.'
                    '${mission.ratingComment != null ? '\n"${mission.ratingComment}"' : ''}',
              ),
              const SizedBox(height: 20),
            ],

            // ── Bouton annulation ──
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: _isCancelling ? null : _cancelMission,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.red),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: Text(_isCancelling
                      ? 'Annulation...'
                      : 'Annuler la mission'),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Widgets helpers ─────────────────────────────────────────────────────────

  Widget _timelineStep({
    required String label,
    required bool isDone,
    required bool isCurrent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Colors.black : Colors.black87,
              ),
            ),
          ),
          if (isCurrent)
            _badge('Actuel', Colors.blue),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12),
      ),
    );
  }

  Widget _alertBox({
    required Color color,
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: color.withOpacity(0.9))),
          ),
        ],
      ),
    );
  }
}

// ─── Widget étoiles ──────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final int selected;
  final void Function(int score) onSelect;

  const _StarRating({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final score = i + 1;
        return GestureDetector(
          onTap: () => onSelect(score),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              score <= selected ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 40,
            ),
          ),
        );
      }),
    );
  }
}
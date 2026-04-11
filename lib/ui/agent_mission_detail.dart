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
  final MissionService _missionService = MissionService();
  final TextEditingController _proofCommentController =
      TextEditingController();

  // États async — un seul à la fois actif pour éviter doubles appuis
  bool _isUpdatingStatus = false;
  bool _isUploadingProof = false;
  bool _isCancelling = false;

  // État preuve
  bool _proofUploadFailed = false;

  @override
  void dispose() {
    _proofCommentController.dispose();
    super.dispose();
  }

  Mission get _mission {
    return _missionService.missions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => widget.mission,
    );
  }

  bool get _anyLoading =>
      _isUpdatingStatus || _isUploadingProof || _isCancelling;

  // ─── Progression statut ───────────────────────────────────────────────────

  Future<void> _updateStatus(
      MissionStatus newStatus, String successMessage) async {
    if (_anyLoading) return;
    setState(() => _isUpdatingStatus = true);

    try {
      await _missionService.updateMissionStatus(_mission.id, newStatus);
      if (!mounted) return;
      setState(() {});
      _showSuccess(successMessage);
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  // ─── Upload preuve (mock — prêt pour vrai backend) ────────────────────────
  //
  //  Structure :  1. simulation compression (TODO: image_picker + flutter_image_compress)
  //               2. simulation upload HTTP (TODO: multipart/form-data)
  //               3. appel addProof avec l'URL retournée
  //
  //  Pour switcher vers un vrai backend :
  //  - remplacer _simulateUpload() par un appel HTTP réel
  //  - passer l'URL retournée à addProof(imagePath: url)

  Future<void> _uploadProof() async {
    final comment = _proofCommentController.text.trim();

    if (comment.isEmpty) {
      _showError('Merci de saisir un commentaire de preuve.');
      return;
    }

    if (_anyLoading) return;

    setState(() {
      _isUploadingProof = true;
      _proofUploadFailed = false;
    });

    try {
      // TODO: remplacer par image_picker + sélection réelle
      final String imagePath = await _simulateImageUpload();

      await _missionService.addProof(
        missionId: _mission.id,
        imagePath: imagePath,
        comment: comment,
      );

      _proofCommentController.clear();
      if (!mounted) return;
      setState(() {});
      _showSuccess('Preuve ajoutée avec succès.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _proofUploadFailed = true);
      _showError(e);
    } finally {
      if (mounted) setState(() => _isUploadingProof = false);
    }
  }

  /// Simule un upload avec délai. Remplacer par HTTP réel plus tard.
  Future<String> _simulateImageUpload() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simule une URL retournée par le backend
    return 'assets/proof_placeholder.jpg';
  }

  // ─── Annulation ───────────────────────────────────────────────────────────

  Future<void> _cancelMission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la mission'),
        content: const Text(
          'Voulez-vous vraiment annuler cette mission ?',
        ),
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
    if (_anyLoading) return;

    setState(() => _isCancelling = true);

    try {
      await _missionService.cancelMission(_mission.id);
      if (!mounted) return;
      setState(() {});
      _showSuccess('Mission annulée.');
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  // ─── Snackbars ────────────────────────────────────────────────────────────

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _showError(Object e) {
    final msg =
        e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  // ─── Labels / couleurs ────────────────────────────────────────────────────

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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mission = _mission;
    final statusColor = _statusColor(mission.status);
    final isCancelled = mission.status == MissionStatus.cancelled;
    final isCompleted = mission.status == MissionStatus.completed;
    final canCancel = _missionService.canCancel(mission);
    final canAddProof = mission.status == MissionStatus.inProgress;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail mission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Infos ──
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (mission.isExpress) _badge('⚡ Express', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('📍 ${mission.address}'),
                    const SizedBox(height: 6),
                    Text('🕒 ${mission.timeSlot}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('📌 Statut : '),
                        _badge(_statusLabel(mission.status), statusColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '💰 Base : ${mission.basePrice.toStringAsFixed(0)} MAD'),
                    const SizedBox(height: 4),
                    Text(
                        '💵 Total : ${mission.totalPrice.toStringAsFixed(0)} MAD'),
                    if (mission.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('📝 ${mission.note}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Mission annulée ──
            if (isCancelled) ...[
              _alertBox(
                color: Colors.red,
                icon: Icons.cancel_outlined,
                message:
                    'Cette mission est annulée. Aucune action disponible.',
              ),
            ],

            // ── Mission terminée ──
            if (isCompleted) ...[
              _alertBox(
                color: Colors.green,
                icon: Icons.check_circle_outline,
                message: 'Mission terminée avec succès.',
              ),
            ],

            // ── Progression (masquée si cancelled ou completed) ──
            if (!isCancelled && !isCompleted) ...[
              _sectionTitle('Progression'),
              const SizedBox(height: 10),

              // Bouton : En route
              _actionButton(
                label: '🚀 Mettre en route',
                loadingLabel: 'Mise en route...',
                isLoading: _isUpdatingStatus,
                isEnabled: mission.status == MissionStatus.accepted,
                onPressed: () => _updateStatus(
                  MissionStatus.onTheWay,
                  'Vous êtes en route.',
                ),
                hint: mission.status == MissionStatus.onTheWay ||
                        mission.status == MissionStatus.inProgress
                    ? null // déjà passé
                    : null,
              ),

              const SizedBox(height: 10),

              // Bouton : Démarrer
              _actionButton(
                label: '▶️ Démarrer la mission',
                loadingLabel: 'Démarrage...',
                isLoading: _isUpdatingStatus,
                isEnabled: mission.status == MissionStatus.onTheWay,
                onPressed: () => _updateStatus(
                  MissionStatus.inProgress,
                  'Mission démarrée.',
                ),
              ),

              const SizedBox(height: 10),

              // Bouton : Terminer (nécessite preuve)
              _actionButton(
                label: '✅ Terminer la mission',
                loadingLabel: 'Finalisation...',
                isLoading: _isUpdatingStatus,
                isEnabled: mission.status == MissionStatus.inProgress &&
                    mission.proof != null,
                onPressed: () => _updateStatus(
                  MissionStatus.completed,
                  'Mission terminée.',
                ),
                hint: mission.status == MissionStatus.inProgress &&
                        mission.proof == null
                    ? 'Ajoutez d\'abord une preuve'
                    : null,
              ),

              const SizedBox(height: 24),
            ],

            // ── Preuve (seulement en inProgress) ──
            if (!isCancelled && !isCompleted) ...[
              _sectionTitle('Preuve de mission'),
              const SizedBox(height: 10),

              if (mission.proof == null) ...[
                TextField(
                  controller: _proofCommentController,
                  maxLines: 3,
                  enabled: canAddProof && !_isUploadingProof,
                  decoration: InputDecoration(
                    labelText: 'Commentaire de preuve',
                    border: const OutlineInputBorder(),
                    hintText: canAddProof
                        ? 'Décrivez la livraison...'
                        : 'Disponible quand la mission est en cours',
                  ),
                ),
                const SizedBox(height: 10),

                // Upload avec état loading + retry
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canAddProof && !_anyLoading
                        ? _uploadProof
                        : null,
                    icon: _isUploadingProof
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : Icon(_proofUploadFailed
                            ? Icons.refresh
                            : Icons.upload_outlined),
                    label: Text(
                      _isUploadingProof
                          ? 'Upload en cours...'
                          : _proofUploadFailed
                              ? 'Réessayer l\'upload'
                              : 'Uploader la preuve',
                    ),
                  ),
                ),

                if (_proofUploadFailed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'L\'upload a échoué. Vérifie ta connexion et réessaie.',
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
              ] else ...[
                // Preuve déjà uploadée
                Card(
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✅ Preuve enregistrée',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            '🖼️ ${mission.proof!.imagePath ?? 'Aucune image'}'),
                        const SizedBox(height: 4),
                        Text(
                            '💬 ${mission.proof!.comment ?? 'Aucun commentaire'}'),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],

            // ── Preuve visible en completed ──
            if (isCompleted && mission.proof != null) ...[
              _sectionTitle('Preuve de mission'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '🖼️ ${mission.proof!.imagePath ?? 'Aucune image'}'),
                      const SizedBox(height: 4),
                      Text(
                          '💬 ${mission.proof!.comment ?? 'Aucun commentaire'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Rating reçu (visible pour l'agent) ──
            if (mission.ratingScore != null) ...[
              _sectionTitle('Évaluation client'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < mission.ratingScore!
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 26,
                          ),
                        ),
                      ),
                      if (mission.ratingComment != null &&
                          mission.ratingComment!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('"${mission.ratingComment}"'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  onPressed: _anyLoading ? null : _cancelMission,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.red),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: Text(
                      _isCancelling ? 'Annulation...' : 'Annuler la mission'),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Widgets helpers ──────────────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _alertBox(
      {required Color color,
      required IconData icon,
      required String message}) {
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

  /// Bouton d'action avec état disabled, loading, et hint optionnel.
  Widget _actionButton({
    required String label,
    required String loadingLabel,
    required bool isLoading,
    required bool isEnabled,
    required VoidCallback onPressed,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isEnabled && !isLoading) ? onPressed : null,
            child: isLoading && isEnabled
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(loadingLabel),
                    ],
                  )
                : Text(label),
          ),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              hint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }
}
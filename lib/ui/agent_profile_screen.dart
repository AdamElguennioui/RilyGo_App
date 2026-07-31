import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false));
      return const Scaffold(body: SizedBox.shrink());
    }

    final missions   = MissionService().getAgentMissions(user.id);
    final completed  = missions.where((m) => m.status == MissionStatus.completed).toList();
    final inProgress = missions.where((m) =>
        m.status == MissionStatus.accepted  ||
        m.status == MissionStatus.onTheWay  ||
        m.status == MissionStatus.inProgress).toList();

    // Compute average rating from missions that have been rated.
    final rated = completed.where((m) => m.ratingScore != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.map((m) => m.ratingScore!).reduce((a, b) => a + b) / rated.length;

    // Simulated revenue from completed missions.
    final revenue = completed.fold(0.0, (sum, m) => sum + m.totalPrice);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mon espace expert'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Center(
            child: ProfileHeader(
              phone: user.phone,
              badgeLabel: 'Expert RileyQueue',
              badgeColor: RilyColors.gold,
            ),
          ),

          const SizedBox(height: 32),

          // ── Stats ─────────────────────────────────────────────────────────
          const SectionHeader('STATISTIQUES'),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: ProfileStatTile(
                label: 'Clôturés',
                value: '${completed.length}',
                color: RilyColors.success,
                icon: Icons.check_circle_outline_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: ProfileStatTile(
                label: 'En cours',
                value: '${inProgress.length}',
                color: RilyColors.statusInProgress,
                icon: Icons.pending_actions_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: ProfileStatTile(
                label: 'Note moy.',
                value: avgRating != null
                    ? avgRating.toStringAsFixed(1)
                    : '—',
                color: RilyColors.warning,
                icon: Icons.star_rounded,
              )),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: ProfileStatTile(
                label: 'Revenus',
                value: '${revenue.toStringAsFixed(0)} MAD',
                color: RilyColors.accent,
                icon: Icons.account_balance_wallet_outlined,
              )),
              const SizedBox(width: 12),
              Expanded(child: ProfileStatTile(
                label: 'Avis clients',
                value: '${rated.length}',
                color: RilyColors.info,
                icon: Icons.rate_review_outlined,
              )),
              const SizedBox(width: 12),
              Expanded(child: ProfileStatTile(
                label: 'Total',
                value: '${missions.length}',
                color: RilyColors.textSecondary,
                icon: Icons.folder_outlined,
              )),
            ],
          ),

          const SizedBox(height: 32),

          // ── Compte ────────────────────────────────────────────────────────
          const SectionHeader('COMPTE'),
          const SizedBox(height: 14),

          RilyCard(
            child: Column(
              children: [
                ProfileInfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Numéro de téléphone',
                  value: user.phone,
                ),
                const Divider(height: 20),
                const ProfileInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: "Date d'inscription",
                  value: 'Février 2025',
                ),
                const Divider(height: 20),
                const ProfileInfoRow(
                  icon: Icons.verified_rounded,
                  label: 'Statut',
                  value: 'Expert vérifié',
                  iconColor: RilyColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Support ───────────────────────────────────────────────────────
          const SectionHeader('SUPPORT'),
          const SizedBox(height: 14),

          RilyCard(
            child: Column(
              children: [
                ProfileInfoRow(
                  icon: Icons.headset_mic_outlined,
                  label: 'Assistance',
                  value: 'Contacter le support',
                  onTap: () => showSuccessSnack(context, 'Support disponible prochainement.'),
                ),
                const Divider(height: 20),
                ProfileInfoRow(
                  icon: Icons.bug_report_outlined,
                  label: 'Signaler un problème',
                  value: 'Envoyer un rapport',
                  onTap: () => showSuccessSnack(context, 'Rapport envoyé. Merci !'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── À propos ──────────────────────────────────────────────────────
          const SectionHeader('À PROPOS'),
          const SizedBox(height: 14),

          RilyCard(
            child: Column(
              children: const [
                ProfileInfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: '1.0.0 — Sprint 1',
                ),
                Divider(height: 20),
                ProfileInfoRow(
                  icon: Icons.description_outlined,
                  label: 'Conditions d\'utilisation',
                  value: 'Disponible prochainement',
                ),
                Divider(height: 20),
                ProfileInfoRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Politique de confidentialité',
                  value: 'Disponible prochainement',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          ProfileLogoutButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              }
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

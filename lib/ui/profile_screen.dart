import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import '../models/mission.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final ms   = MissionService();
    final user = auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false));
      return const Scaffold(body: SizedBox.shrink());
    }

    final missions = ms.getClientMissions(user.id);
    final active = missions
        .where((m) =>
            m.status != MissionStatus.completed &&
            m.status != MissionStatus.cancelled)
        .length;
    final completed =
        missions.where((m) => m.status == MissionStatus.completed).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mon compte'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Avatar + phone ────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: RilyColors.accentDim,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: RilyColors.accent.withValues(alpha: 0.3),
                        width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded,
                        color: RilyColors.accent, size: 36),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.phone,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: RilyColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RilyColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: RilyColors.accent.withValues(alpha: 0.25)),
                  ),
                  child: const Text(
                    'Client',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RilyColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Stats ──────────────────────────────────────────────────────────
          const SectionHeader('MES DOSSIERS'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'En cours',
                  value: '$active',
                  color: RilyColors.info,
                  icon: Icons.pending_actions_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Clôturés',
                  value: '$completed',
                  color: RilyColors.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Total',
                  value: '${missions.length}',
                  color: RilyColors.accent,
                  icon: Icons.folder_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Infos ──────────────────────────────────────────────────────────
          const SectionHeader('INFORMATIONS'),
          const SizedBox(height: 14),
          RilyCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Numéro de téléphone',
                  value: user.phone,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.shield_outlined,
                  label: 'Données',
                  value: 'Chiffrées et sécurisées',
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Confidentialité',
                  value: 'Accord signé par chaque expert',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Logout ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: RilyColors.error,
                side: BorderSide(
                    color: RilyColors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (r) => false);
                }
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RilyCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: RilyColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RilyColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12, color: RilyColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: RilyColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

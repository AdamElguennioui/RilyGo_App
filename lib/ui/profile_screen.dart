import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false));
      return const Scaffold(body: SizedBox.shrink());
    }

    final missions  = MissionService().getClientMissions(user.id);
    final active    = missions.where((m) =>
        m.status != MissionStatus.completed &&
        m.status != MissionStatus.cancelled).length;
    final completed = missions.where((m) => m.status == MissionStatus.completed).length;

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
          Center(
            child: ProfileHeader(
              phone: user.phone ?? user.email ?? '',
              badgeLabel: 'Client',
            ),
          ),

          const SizedBox(height: 32),
          const SectionHeader('MES DOSSIERS'),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: ProfileStatTile(
                label: 'En cours', value: '$active',
                color: RilyColors.info, icon: Icons.pending_actions_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: ProfileStatTile(
                label: 'Clôturés', value: '$completed',
                color: RilyColors.success, icon: Icons.check_circle_outline_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: ProfileStatTile(
                label: 'Total', value: '${missions.length}',
                color: RilyColors.accent, icon: Icons.folder_outlined,
              )),
            ],
          ),

          const SizedBox(height: 32),
          const SectionHeader('INFORMATIONS'),
          const SizedBox(height: 14),

          RilyCard(
            child: Column(
              children: [
                ProfileInfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Numéro de téléphone',
                  value: user.phone ?? '—',
                ),
                const Divider(height: 20),
                const ProfileInfoRow(
                  icon: Icons.shield_outlined,
                  label: 'Données',
                  value: 'Chiffrées et sécurisées',
                ),
                const Divider(height: 20),
                const ProfileInfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Confidentialité',
                  value: 'Accord signé par chaque expert',
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

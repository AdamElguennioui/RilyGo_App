import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import '../models/mission.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final AuthService _auth = AuthService();
  final MissionService _ms = MissionService();

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final available = _ms.getAvailableMissions().length;
    final myMissions = _ms.getAgentMissions(user.id);
    final inProgress = myMissions
        .where((m) =>
            m.status == MissionStatus.accepted ||
            m.status == MissionStatus.onTheWay ||
            m.status == MissionStatus.inProgress)
        .length;
    final completed = myMissions
        .where((m) => m.status == MissionStatus.completed)
        .length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: RilyColors.bg,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rily Agent',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: RilyColors.accent,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Bonjour 🤝',
                    style: TextStyle(
                      fontSize: 13,
                      color: RilyColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: RilyColors.textSecondary),
                  onPressed: _logout,
                  tooltip: 'Déconnexion',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child:
                    Container(height: 1, color: RilyColors.surfaceBorder),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Stats ──
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              label: 'Disponibles',
                              value: '$available',
                              color: RilyColors.info,
                              emoji: '📋')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              label: 'En cours',
                              value: '$inProgress',
                              color: RilyColors.statusInProgress,
                              emoji: '⚡')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              label: 'Terminées',
                              value: '$completed',
                              color: RilyColors.success,
                              emoji: '✅')),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── CTA principal ──
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/agentMissions')
                        .then((_) => setState(() {})),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9B8BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: RilyColors.accent.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  available > 0
                                      ? '$available mission${available > 1 ? 's' : ''} disponible${available > 1 ? 's' : ''}'
                                      : 'Voir mes missions',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  available > 0
                                      ? 'Accepte une mission maintenant'
                                      : 'Gérer ma progression',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Missions en cours ──
                  if (inProgress > 0) ...[
                    const SectionHeader('MES MISSIONS EN COURS'),
                    const SizedBox(height: 14),
                    ...myMissions
                        .where((m) =>
                            m.status == MissionStatus.accepted ||
                            m.status == MissionStatus.onTheWay ||
                            m.status == MissionStatus.inProgress)
                        .map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ActiveMissionCard(
                                mission: m,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/missionDetail',
                                  arguments: m,
                                ).then((_) => setState(() {})),
                              ),
                            )),
                    const SizedBox(height: 16),
                  ],

                  if (available == 0 && inProgress == 0)
                    const EmptyState(
                      emoji: '🎯',
                      title: 'Rien pour le moment',
                      subtitle:
                          'Reviens plus tard, de nouvelles missions arrivent régulièrement.',
                    ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String emoji;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return RilyCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
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
          ),
        ],
      ),
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  const _ActiveMissionCard({required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RilyCard(
      onTap: onTap,
      borderColor: mission.status.color.withOpacity(0.25),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mission.status.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child:
                  Text(mission.status.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: RilyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mission.address,
                  style: const TextStyle(
                      fontSize: 13, color: RilyColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: RilyColors.textMuted),
        ],
      ),
    );
  }
}
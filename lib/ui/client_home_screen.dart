import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import '../services/connectivity_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final AuthService _authService = AuthService();
  final MissionService _missionService = MissionService();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivity.onConnectivityChanged.listen((connected) {
      if (mounted) setState(() => _isOffline = !connected);
    });
    _isOffline = !_connectivity.isConnected;
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    if (user.role != UserRole.client) {
      return const Scaffold(
        body: Center(child: Text('Accès réservé aux clients.')),
      );
    }

    final missions = _missionService.getClientMissions(user.id);
    final activeMissions = missions
        .where((m) =>
            m.status != MissionStatus.completed &&
            m.status != MissionStatus.cancelled)
        .toList();
    final pastMissions = missions
        .where((m) =>
            m.status == MissionStatus.completed ||
            m.status == MissionStatus.cancelled)
        .toList();

    return Scaffold(
      body: Column(
        children: [
          ConnectivityBanner(
            isOffline: _isOffline,
            onRetry: () => setState(() {}),
          ),
          Expanded(
            child: RefreshIndicator(
              color: RilyColors.accent,
              onRefresh: () async => setState(() {}),
              child: CustomScrollView(
                slivers: [
                  // ── App Bar ──
                  SliverAppBar(
                    floating: true,
                    backgroundColor: RilyColors.bg,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rily',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: RilyColors.accent,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Bonjour 👋',
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
                      child: Container(
                          height: 1, color: RilyColors.surfaceBorder),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── CTA Nouvelle mission ──
                        _NewMissionButton(
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, '/createMission');
                            setState(() {});
                          },
                        ),

                        const SizedBox(height: 28),

                        // ── Missions actives ──
                        const SectionHeader('MISSIONS EN COURS'),
                        const SizedBox(height: 14),

                        if (activeMissions.isEmpty)
                          const EmptyState(
                            emoji: '🎯',
                            title: 'Aucune mission active',
                            subtitle:
                                'Crée ta première mission pour commencer.',
                          )
                        else
                          ...activeMissions.map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ClientMissionCard(
                                mission: m,
                                onTap: () => _openStatus(m),
                              ),
                            ),
                          ),

                        if (pastMissions.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          const SectionHeader('HISTORIQUE'),
                          const SizedBox(height: 14),
                          ...pastMissions.map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ClientMissionCard(
                                mission: m,
                                onTap: () => _openStatus(m),
                                muted: true,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openStatus(Mission mission) {
    Navigator.pushNamed(context, '/missionStatus', arguments: mission)
        .then((_) => setState(() {}));
  }
}

// ─── Bouton nouvelle mission ─────────────────────────────────────────────────

class _NewMissionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewMissionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
                children: const [
                  Text(
                    'Nouvelle mission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Document, colis, livraison...',
                    style: TextStyle(
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
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte mission client ────────────────────────────────────────────────────

class _ClientMissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final bool muted;

  const _ClientMissionCard({
    required this.mission,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return RilyCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône catégorie
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: RilyColors.accentDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('📦', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.category,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: muted
                            ? RilyColors.textSecondary
                            : RilyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mission.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: RilyColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(mission.status, small: true),
            ],
          ),

          const SizedBox(height: 12),

          // Créneau + prix + express
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: RilyColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  mission.timeSlot,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RilyColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (mission.isExpress) ...[
                const SizedBox(width: 8),
                const ExpressBadge(),
                const SizedBox(width: 8),
              ],
              Text(
                '${mission.totalPrice.toStringAsFixed(0)} MAD',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RilyColors.accent,
                ),
              ),
            ],
          ),

          // Rating stars si completed et noté
          if (mission.status == MissionStatus.completed &&
              mission.ratingScore != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < mission.ratingScore!
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: RilyColors.warning,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${mission.ratingScore}/5',
                  style: const TextStyle(
                      fontSize: 12, color: RilyColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
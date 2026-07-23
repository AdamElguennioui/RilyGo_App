import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rily_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;
  bool _obscure   = true;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _snack('Veuillez remplir tous les champs.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _auth.signIn(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        user.role == UserRole.client ? '/clientHome' : '/agentHome',
      );
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? RilyColors.error : RilyColors.surfaceElevated,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ── Brand ────────────────────────────────────────────────────
                Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: RilyColors.accentDim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: RilyColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text('R',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: RilyColors.accent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('RilyGo',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: RilyColors.textPrimary,
                          letterSpacing: -0.5)),
                ]),

                const SizedBox(height: 40),

                // ── Value prop ───────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: RilyColors.accentDim,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: RilyColors.accent.withValues(alpha: 0.25)),
                  ),
                  child: const Text('Votre concierge administratif',
                      style: TextStyle(
                          fontSize: 12,
                          color: RilyColors.accent,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Déléguez vos\ndémarches\nadministratives.',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: RilyColors.textPrimary,
                      letterSpacing: -1.0,
                      height: 1.1),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Des experts certifiés prennent en charge\nvos formalités de A à Z.',
                  style: TextStyle(
                      fontSize: 15,
                      color: RilyColors.textSecondary,
                      height: 1.6),
                ),
                const SizedBox(height: 32),

                // ── Trust pills ──────────────────────────────────────────────
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TrustPill(
                        icon: Icons.verified_user_outlined,
                        label: 'Experts vérifiés'),
                    _TrustPill(
                        icon: Icons.lock_outline_rounded,
                        label: 'Données sécurisées'),
                    _TrustPill(
                        icon: Icons.track_changes_rounded,
                        label: 'Suivi en temps réel'),
                  ],
                ),
                const SizedBox(height: 40),

                // ── Email ────────────────────────────────────────────────────
                RilyTextField(
                  controller: _emailCtrl,
                  label: 'Adresse email',
                  hint: 'exemple@email.com',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────────────────────
                RilyTextField(
                  controller: _passwordCtrl,
                  label: 'Mot de passe',
                  hint: '••••••••',
                  obscureText: _obscure,
                  enabled: !_isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: RilyColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 20),

                // ── CTA ──────────────────────────────────────────────────────
                RilyButton(
                  label: 'Connexion',
                  loadingLabel: 'Connexion...',
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _signIn,
                ),

                const SizedBox(height: 32),

                // ── Footer ───────────────────────────────────────────────────
                Center(
                  child: Text(
                    'En continuant, vous acceptez nos CGU\net notre politique de confidentialité.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: RilyColors.textMuted,
                        height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RilyColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RilyColors.surfaceBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: RilyColors.accent),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: RilyColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

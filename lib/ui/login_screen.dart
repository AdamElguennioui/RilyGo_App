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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _otpSent = false;
  bool _isLoading = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

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
    _phoneController.dispose();
    _otpController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Veuillez saisir votre numéro de téléphone.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(phone);
      if (!mounted) return;
      setState(() => _otpSent = true);
      _showSnack('Code envoyé — utilisez 1234 pour tester.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Erreur : $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showSnack('Veuillez saisir le code reçu.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _authService.verifyOtp(
        phone: _phoneController.text.trim(),
        otp: otp,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        user.role == UserRole.client ? '/clientHome' : '/agentHome',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Code invalide. Veuillez réessayer.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? RilyColors.error : RilyColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

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

                // ── Brand mark ─────────────────────────────────────────────
                Row(
                  children: [
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
                        child: Text(
                          'R',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: RilyColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'RilyGo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: RilyColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Value proposition (shown only before OTP) ───────────────
                if (!_otpSent) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: RilyColors.accentDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              RilyColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      'Votre concierge administratif',
                      style: TextStyle(
                        fontSize: 12,
                        color: RilyColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Déléguez vos\ndémarches\nadministratives.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: RilyColors.textPrimary,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Des experts certifiés prennent en charge\nvos formalités de A à Z.',
                    style: TextStyle(
                      fontSize: 15,
                      color: RilyColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Trust pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
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
                ],

                // ── OTP step header ─────────────────────────────────────────
                if (_otpSent) ...[
                  const Text(
                    'Code de vérification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: RilyColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Un code à 4 chiffres a été envoyé\nau ${_phoneController.text}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: RilyColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // ── Phone field ─────────────────────────────────────────────
                RilyTextField(
                  controller: _phoneController,
                  label: 'Numéro de téléphone',
                  hint: '06 XX XX XX XX',
                  keyboardType: TextInputType.phone,
                  enabled: !_otpSent && !_isLoading,
                ),

                // ── OTP field ───────────────────────────────────────────────
                if (_otpSent) ...[
                  const SizedBox(height: 14),
                  RilyTextField(
                    controller: _otpController,
                    label: 'Code à 4 chiffres',
                    hint: '1234',
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                  ),
                ],

                const SizedBox(height: 20),

                // ── Primary CTA ─────────────────────────────────────────────
                RilyButton(
                  label: _otpSent ? 'Accéder à mon espace' : 'Continuer',
                  loadingLabel:
                      _otpSent ? 'Vérification...' : 'Envoi du code...',
                  isLoading: _isLoading,
                  icon: _otpSent
                      ? Icons.arrow_forward_rounded
                      : Icons.phone_outlined,
                  onPressed: _otpSent ? _verifyOtp : _sendOtp,
                ),

                if (_otpSent) ...[
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              }),
                      child: const Text(
                        'Modifier le numéro',
                        style: TextStyle(
                            color: RilyColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // ── Test mode card ──────────────────────────────────────────
                RilyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ENVIRONNEMENT DE TEST',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: RilyColors.accent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      _TestHintRow(
                          icon: Icons.person_outline_rounded,
                          text: 'Numéro se terminant par 1 → Expert'),
                      SizedBox(height: 6),
                      _TestHintRow(
                          icon: Icons.badge_outlined,
                          text: 'Autre numéro → Client'),
                      SizedBox(height: 6),
                      _TestHintRow(
                          icon: Icons.key_outlined,
                          text: 'Code OTP : 1234'),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: RilyColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RilyColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: RilyColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: RilyColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestHintRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TestHintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: RilyColors.textMuted),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
              fontSize: 13, color: RilyColors.textSecondary),
        ),
      ],
    );
  }
}

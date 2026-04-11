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
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
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
      showErrorSnack(context, 'Saisis ton numéro de téléphone.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(phone);
      if (!mounted) return;
      setState(() => _otpSent = true);
      showSuccessSnack(context, 'Code envoyé — utilise 1234 pour tester.');
    } catch (e) {
      if (!mounted) return;
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      showErrorSnack(context, 'Saisis le code reçu.');
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
      showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo / titre
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: RilyColors.accentDim,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: RilyColors.accent.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text('R',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: RilyColors.accent,
                        )),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Bienvenue sur Rily',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: RilyColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Saisis le code envoyé au\n${_phoneController.text}'
                      : 'Entre ton numéro pour recevoir un code.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: RilyColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Champ téléphone
                RilyTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  hint: '06 XX XX XX XX',
                  keyboardType: TextInputType.phone,
                  enabled: !_otpSent && !_isLoading,
                ),

                // Champ OTP (apparaît après envoi)
                if (_otpSent) ...[
                  const SizedBox(height: 16),
                  RilyTextField(
                    controller: _otpController,
                    label: 'Code de vérification',
                    hint: '1234',
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                  ),
                ],

                const SizedBox(height: 24),

                // Bouton principal
                RilyButton(
                  label: _otpSent ? 'Vérifier le code' : 'Envoyer le code',
                  loadingLabel: _otpSent ? 'Vérification...' : 'Envoi...',
                  isLoading: _isLoading,
                  onPressed: _otpSent ? _verifyOtp : _sendOtp,
                ),

                if (_otpSent) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              });
                            },
                      child: const Text(
                        'Modifier le numéro',
                        style: TextStyle(
                            color: RilyColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Aide test terrain
                RilyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MODE TEST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: RilyColors.accent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 10),
                      _TestHintRow(
                          emoji: '📱',
                          text: 'Numéro finissant par 1 → Agent'),
                      SizedBox(height: 6),
                      _TestHintRow(
                          emoji: '👤',
                          text: 'Autre numéro → Client'),
                      SizedBox(height: 6),
                      _TestHintRow(emoji: '🔑', text: 'OTP = 1234'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestHintRow extends StatelessWidget {
  final String emoji;
  final String text;
  const _TestHintRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
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
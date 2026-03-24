import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final AuthService authService = AuthService();

  bool otpSent = false;
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  // ── Design tokens ──────────────────────────────────────────────
  static const Color _navy      = Color(0xFF1E3A8A);
  static const Color _navyLight = Color(0xFF2D55C8);
  static const Color _navyDim   = Color(0xFFE8EEF9);
  static const Color _white     = Color(0xFFFFFFFF);
  static const Color _bg        = Color(0xFFF8F9FC);
  static const Color _textPrimary = Color(0xFF0F1729);
  static const Color _textMuted   = Color(0xFF6B7280);
  static const Color _border      = Color(0xFFDDE3F0);
  static const Color _error       = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _triggerEntryAnimation() {
    _animController
      ..reset()
      ..forward();
  }

  Future<void> _handleAction() async {
    if (!otpSent) {
      await _sendOtp();
    } else {
      await _verifyOtp();
    }
  }

  Future<void> _sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Merci de saisir un numéro de téléphone.');
      return;
    }
    setState(() => isLoading = true);
    try {
      await authService.sendOtp(phone);
      if (!mounted) return;
      setState(() => otpSent = true);
      _triggerEntryAnimation();
      _showSnack('Code OTP envoyé. Utilise 1234 pour le test.');
    } catch (e) {
      _showSnack('Erreur : $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      _showSnack('Merci de saisir le code OTP.');
      return;
    }
    setState(() => isLoading = true);
    try {
      final user = await authService.verifyOtp(phone: phone, otp: otp);
      if (!mounted) return;
      if (user.role == UserRole.client) {
        Navigator.pushReplacementNamed(context, '/clientHome');
      } else {
        Navigator.pushReplacementNamed(context, '/agentHome');
      }
    } catch (e) {
      _showSnack('Erreur : $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? _error : _navy,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _white,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isError ? _error.withOpacity(0.3) : _border,
          ),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 52),

                  // ── Logo ────────────────────────────────────
                  const _RilyQueueLogo(),

                  const SizedBox(height: 40),

                  // ── Separator ───────────────────────────────
                  Container(height: 1, color: _border),

                  const SizedBox(height: 36),

                  // ── Headline ────────────────────────────────
                  Text(
                    otpSent ? 'Vérification OTP' : 'Connexion',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    otpSent
                        ? 'Entrez le code à 4 chiffres envoyé par SMS.'
                        : 'Entrez votre numéro pour recevoir un code de connexion.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textMuted,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Phone field ─────────────────────────────
                  const _FieldLabel(label: 'Numéro de téléphone'),
                  const SizedBox(height: 6),
                  _StyledTextField(
                    controller: phoneController,
                    hint: '+212 6XX XXX XXX',
                    keyboardType: TextInputType.phone,
                    enabled: !otpSent && !isLoading,
                    prefixIcon: Icons.phone_outlined,
                  ),

                  // ── OTP field (animated) ────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: otpSent
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const _FieldLabel(label: 'Code OTP'),
                        const SizedBox(height: 6),
                        _StyledTextField(
                          controller: otpController,
                          hint: '1  2  3  4',
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          prefixIcon: Icons.shield_outlined,
                          maxLength: 4,
                          letterSpacing: 6,
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: isLoading ? null : _sendOtp,
                          child: Text(
                            'Renvoyer le code',
                            style: TextStyle(
                              fontSize: 13,
                              color: isLoading ? _textMuted : _navyLight,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: _navyLight,
                            ),
                          ),
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 36),

                  // ── Primary CTA ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        disabledBackgroundColor: _navy.withOpacity(0.4),
                        foregroundColor: _white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(_white),
                        ),
                      )
                          : Text(
                        otpSent
                            ? 'Vérifier le code'
                            : 'Envoyer le code',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Dev hint card ───────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _navyDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _navy.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: _navy.withOpacity(0.65)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Mode test  •  OTP : 1234\n'
                                'N° terminant par 1 → Agent   |   Autre → Client',
                            style: TextStyle(
                              fontSize: 12,
                              color: _navy,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────
class _RilyQueueLogo extends StatelessWidget {
  const _RilyQueueLogo();

  static const Color _navy      = Color(0xFF1E3A8A);
  static const Color _navyLight = Color(0xFF2D55C8);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_navy, _navyLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'R',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Rily',
                style: TextStyle(
                  color: _navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Queue',
                style: TextStyle(
                  color: _navyLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Field label ───────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
        letterSpacing: 0.1,
      ),
    );
  }
}

// ── Text field ────────────────────────────────────────────────────
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final IconData prefixIcon;
  final int? maxLength;
  final double letterSpacing;

  static const Color _navy        = Color(0xFF1E3A8A);
  static const Color _white       = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF0F1729);
  static const Color _textMuted   = Color(0xFF9CA3AF);
  static const Color _border      = Color(0xFFDDE3F0);

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.enabled,
    required this.prefixIcon,
    this.maxLength,
    this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
        letterSpacing: letterSpacing,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, color: _navy.withOpacity(0.5), size: 20),
        ),
        prefixIconConstraints:
        const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: enabled ? _white : const Color(0xFFF3F4F6),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border.withOpacity(0.5)),
        ),
      ),
    );
  }
}
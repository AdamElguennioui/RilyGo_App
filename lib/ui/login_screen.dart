import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final AuthService authService = AuthService();

  bool otpSent = false;
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de saisir un numéro de téléphone.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.sendOtp(phone);

      if (!mounted) return;

      setState(() {
        otpSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP envoyé. Utilise 1234 pour le test.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de saisir le code OTP.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await authService.verifyOtp(
        phone: phone,
        otp: otp,
      );

      if (!mounted) return;

      if (user.role == UserRole.client) {
        Navigator.pushReplacementNamed(context, '/clientHome');
      } else {
        Navigator.pushReplacementNamed(context, '/agentHome');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              enabled: !otpSent && !isLoading,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (otpSent)
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Entrer OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleAction,
                child: Text(
                  isLoading
                      ? 'Chargement...'
                      : (otpSent ? 'Vérifier OTP' : 'Envoyer OTP'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Test rapide :\n'
              '- numéro finissant par 1 = agent\n'
              '- autre numéro = client\n'
              '- OTP = 1234',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
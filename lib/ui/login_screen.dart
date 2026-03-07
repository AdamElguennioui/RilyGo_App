import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final authService = AuthService();
  bool otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!otpSent)
              TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
            if (otpSent)
              TextField(controller: otpController, decoration: InputDecoration(labelText: "Enter OTP")),
            ElevatedButton(
              onPressed: () async {
                if (!otpSent) {
                  await authService.sendOtp(phoneController.text);
                  setState(() => otpSent = true);
                } else {
                  bool success = await authService.verifyOtp(otpController.text);
                  if (success) Navigator.pushNamed(context, "/createMission");
                }
              },
              child: Text(otpSent ? "Verify OTP" : "Send OTP"),
            )
          ],
        ),
      ),
    );
  }
}

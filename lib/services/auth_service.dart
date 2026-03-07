class AuthService {
  // OTP mock
  static const String mockOtp = "1234";

  Future<bool> sendOtp(String phone) async {
    print("OTP envoyé à $phone");
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    return otp == mockOtp;
  }
}

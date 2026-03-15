import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_Mate/features/onboarding/onboardingPage.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // OTP controllers
  //final _otpFormKey = GlobalKey<FormState>();
  //final _otpController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // Step 1: Create account in Firebase
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final token = await credential.user?.getIdToken();
      if (token == null) throw Exception('Failed to get Firebase token');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_token', token);
      await prefs.setBool('onboarding_complete', true);

      // Step 2: Sync with backend (non-blocking — backend down ≠ signup failure)
      try {
        final backendResp = await Dio().post(
          'http://192.168.0.105:8000/api/user/sync',
          data: {
            'name': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        debugPrint('BACKEND RESPONSE: ${backendResp.data}');
      } catch (backendErr) {
        // Backend sync failed — log it but don't block the user
        debugPrint('⚠️ Backend sync failed (non-fatal): $backendErr');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('SIGNUP ERROR: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Signup failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: size.height * 0.28,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0D7377),
                        Color(0xFF14A085),
                        Color(0xFF1EBEA5),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: size.width * 0.3,
                            height: size.width * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.18),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person_add_alt_1,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildSignUpForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Account ✨",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D7377),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Join millions of travellers worldwide",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),

            _buildLabel("Username"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _usernameController,
              hint: "Your full name",
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Enter your name" : null,
            ),
            const SizedBox(height: 16),

            _buildLabel("Email Address"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _emailController,
              hint: "you@example.com",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter your email";
                if (!v.contains('@')) return "Enter a valid email";
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildLabel("Password"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _passwordController,
              hint: "Min 8 characters",
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF14A085),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter a password";
                if (v.length < 8) return "Password min 8 characters";
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildLabel("Confirm Password"),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: "Re-enter your password",
              icon: Icons.lock_outline,
              obscure: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF14A085),
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Confirm your password";
                if (v != _passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),
            const SizedBox(height: 26),

            _buildPrimaryButton(
              label: "Sign Up",
              onPressed: _isLoading ? null : _handleSignUp,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 22),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildSocialRow(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?  ",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: Color(0xFF0D7377),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final token = await userCredential.user?.getIdToken();
      if (token == null || token.isEmpty) {
        throw Exception('Failed to finalize Google Sign-In with Firebase.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_token', token);
      await prefs.setBool('onboarding_complete', true);

      // Sync with your backend
      // TODO: Move base URL to a config/env file.
      final response = await Dio().post(
        'http://192.168.0.105:8000/api/user/sync',
        data: {
          'name': userCredential.user?.displayName ?? gUser.displayName ?? '',
          'email': userCredential.user?.email ?? gUser.email,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      debugPrint('BACKEND RESPONSE: ${response.data}');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('GOOGLE SIGN IN ERROR: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google Sign-In failed')),
      );
    } catch (e) {
      debugPrint('GOOGLE SIGN IN ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ──

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0xFFFFC107).withOpacity(0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
      letterSpacing: 0.2,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF14A085), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF4FDFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF14A085), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDivider() => Row(
    children: [
      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          "Or",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
    ],
  );

  Widget _buildSocialRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _socialButton(
        icon: _googleIcon(),
        onTap: _isLoading ? () {} : _handleGoogleSignIn,
      ),
      const SizedBox(width: 16),
      _socialButton(
        icon: const Icon(Icons.apple, size: 24, color: Colors.black),
        onTap: () {},
      ),
      const SizedBox(width: 16),
      _socialButton(
        icon: const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)),
        onTap: () {},
      ),
    ],
  );

  Widget _socialButton({required Widget icon, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 58,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      );

  Widget _googleIcon() => const Text(
    'G',
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFF4285F4),
      fontFamily: 'serif',
    ),
  );
}

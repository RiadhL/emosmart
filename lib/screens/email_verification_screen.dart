import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_entrance.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = AuthService();
  bool _checking = false;
  bool _resending = false;

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (!mounted) return;
      if (verified) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final profile = await _auth.getProfile(uid);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.textPrimary,
            content: Text(
              'Email not verified yet. Please check your inbox.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await _auth.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.brandPurple,
          content: Text(
            'Verification email resent. Please check your inbox.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.coral,
          content: Text(
            'Could not resend email. Try again later.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _backToLogin() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEEE9FF), Color(0xFFF8F7FF)],
              ),
            ),
          ),
          Positioned(top: -40, right: -40,
            child: Container(width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: const Color(0xFFA78BFA).withOpacity(0.12)))),
          Positioned(bottom: 60, left: -30,
            child: Container(width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: const Color(0xFFFF6B9D).withOpacity(0.08)))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email icon
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 0),
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.brandPurpleLight.withOpacity(0.2),
                            AppTheme.brandPurple.withOpacity(0.15),
                          ],
                        ),
                        border: Border.all(
                            color: AppTheme.brandPurpleLight.withOpacity(0.4),
                            width: 2),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 52,
                        color: AppTheme.brandPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      'Verify your email',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 180),
                    child: Text(
                      widget.email,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.brandPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),

                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 240),
                    child: Text(
                      'We sent you a verification link. Please check your inbox and click the link to activate your account.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // I've verified button
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 320),
                    child: GestureDetector(
                      onTap: _checking ? null : _checkVerified,
                      child: Container(
                        width: double.infinity, height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _checking
                                ? [const Color(0xFF7C6FF7).withOpacity(0.6),
                                   const Color(0xFF5B4FCF).withOpacity(0.6)]
                                : const [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                          ),
                          boxShadow: _checking ? [] : AppTheme.buttonShadow,
                        ),
                        child: Center(
                          child: _checking
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : Text("I've verified my email ✓",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Resend button
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 380),
                    child: SizedBox(
                      width: double.infinity, height: 56,
                      child: OutlinedButton(
                        onPressed: _resending ? null : _resend,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppTheme.brandPurple, width: 1.5),
                          foregroundColor: AppTheme.brandPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: _resending
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: AppTheme.brandPurple, strokeWidth: 2.5))
                            : Text('Resend verification email',
                                style: GoogleFonts.poppins(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 440),
                    child: TextButton(
                      onPressed: _backToLogin,
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary),
                      child: Text('Back to login',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w500)),
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
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_entrance.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _nameCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ageCtrl     = TextEditingController(text: '8');
  final _auth        = AuthService();
  bool _loading  = false;
  bool _obscure  = true;
  bool _obscure2 = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 8;
      await _auth.signUp(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
        name:     _nameCtrl.text.trim(),
        age:      age,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) =>
              EmailVerificationScreen(email: _emailCtrl.text.trim())));
    } catch (e) {
      setState(() => _error = _friendly(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendly(String raw) {
    if (raw.contains('email-already-in-use')) return 'This email is already registered.';
    if (raw.contains('weak-password'))        return 'Password is too weak. Use 6+ characters.';
    if (raw.contains('invalid-email'))        return 'Please enter a valid email.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEEE9FF), Color(0xFFF8F7FF)],
              ),
            ),
          ),
          // Decorative circles
          Positioned(top: -40, right: -40,
            child: Container(width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: const Color(0xFFA78BFA).withOpacity(0.12)))),
          Positioned(bottom: 60, left: -30,
            child: Container(width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: const Color(0xFFFF6B9D).withOpacity(0.08)))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.8),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppTheme.textPrimary),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create account',
                              style: GoogleFonts.poppins(
                                  fontSize: 28, fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary)),
                          const SizedBox(height: 4),
                          Text('One account · one child',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w400,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 160),
                      child: _GlassField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'parent@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 220),
                      child: _GlassField(
                        controller: _nameCtrl,
                        label: "Child's first name",
                        hint: 'e.g. Alex',
                        icon: Icons.child_care_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 280),
                      child: _GlassField(
                        controller: _ageCtrl,
                        label: "Child's age",
                        hint: 'e.g. 8',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return 'Enter a valid age';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 340),
                      child: _GlassField(
                        controller: _passCtrl,
                        label: 'Password',
                        hint: 'at least 6 characters',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20, color: AppTheme.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'At least 6 characters' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 400),
                      child: _GlassField(
                        controller: _confirmCtrl,
                        label: 'Confirm password',
                        hint: 'same as above',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure2,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20, color: AppTheme.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                        ),
                        validator: (v) =>
                            v != _passCtrl.text ? 'Passwords do not match' : null,
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      AnimatedEntrance(
                          child: _ErrorBanner(message: _error!)),
                    ],

                    const SizedBox(height: 32),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 480),
                      child: GestureDetector(
                        onTap: _loading ? null : _submit,
                        child: Container(
                          width: double.infinity, height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _loading
                                  ? [const Color(0xFF7C6FF7).withOpacity(0.6),
                                     const Color(0xFF5B4FCF).withOpacity(0.6)]
                                  : const [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
                            ),
                            boxShadow: _loading ? [] : AppTheme.buttonShadow,
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text('Create account →',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 520),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: AppTheme.textSecondary),
                              children: [
                                TextSpan(
                                  text: 'Log in',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTheme.brandPurple,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared glass input field ──────────────────────────────────────────────────

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              textCapitalization: textCapitalization,
              style: GoogleFonts.poppins(
                  fontSize: 15, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                    fontSize: 14, color: AppTheme.textSecondary),
                prefixIcon: Icon(icon, size: 20, color: AppTheme.brandPurple),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Colors.white.withOpacity(0.85),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.8), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.8), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppTheme.brandPurple, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.coral),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppTheme.coral, width: 1.5),
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.coralLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.coral, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.coral)),
          ),
        ],
      ),
    );
  }
}

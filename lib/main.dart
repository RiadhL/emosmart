import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp();
  runApp(const EmoSmartApp());
}

class EmoSmartApp extends StatelessWidget {
  const EmoSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmoSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AuthGate(),
    );
  }
}

/// Decides whether to show the Welcome screen or the Home screen
/// based on the current Firebase auth state.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        if (snap.hasData && snap.data != null) {
          // User is signed in — load their profile then show home
          return _ProfileLoader(uid: snap.data!.uid);
        }
        return const WelcomeScreen();
      },
    );
  }
}

class _ProfileLoader extends StatelessWidget {
  final String uid;

  const _ProfileLoader({required this.uid});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return FutureBuilder(
      future: auth.getProfile(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        return HomeScreen(profile: snap.data);
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('😊', style: TextStyle(fontSize: 80)),
            SizedBox(height: 20),
            Text('EmoSmart',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 1.5)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}

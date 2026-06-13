import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/navigation/main_navigation_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: OxFlowApp()));
}

class OxFlowApp extends StatelessWidget {
  const OxFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OxFlow',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E5A8),
          surface: const Color(0xFF141E2E),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

/// Checks stored token on startup and routes to Login or Home.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // While checking stored token show a branded splash
    if (authState.isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1220),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart, size: 70, color: Color(0xFF00E5A8)),
              SizedBox(height: 16),
              Text(
                'OxFlow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
              ),
            ],
          ),
        ),
      );
    }

    return authState.isAuthenticated
        ? const MainNavigationScreen()
        : LoginScreen();
  }
}

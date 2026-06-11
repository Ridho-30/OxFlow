import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/scanner/scanner_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const OxFlowApp());
}

class OxFlowApp extends StatelessWidget {
  const OxFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OxFlow',
      home: LoginScreen(),
    );
  }
}
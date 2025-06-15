import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}

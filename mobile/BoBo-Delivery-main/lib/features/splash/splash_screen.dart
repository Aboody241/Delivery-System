import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnBoarding();
  }

  void _navigateToOnBoarding() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final isLoggedIn = await context.read<AuthRepository>().isLoggedIn();
        if (mounted) {
          if (isLoggedIn) {
            Navigator.pushReplacementNamed(context, AppRoutes.mainNav);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.onBoarding);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/consts/splash_background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            left: 100,
            right: 100,
            top: 300,
            child: Image.asset(
              "assets/consts/Logo.png",
              width: 120,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

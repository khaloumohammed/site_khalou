// lib/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_state.dart';

/// Écran de démarrage avec initialisation du BLoC
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigationHandled = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialise l'application et déclenche la vérification de connexion
  void _initializeApp() {
    Future.microtask(() {
      if (mounted) {
        context.read<GoogleSheetCubit>().checkInitialConnection();
      }
    });
  }

  /// Gère la navigation en fonction de l'état du Cubit
  void _handleNavigation(SheetState state) {
    if (_navigationHandled) return;

    if (state is SheetSelection) {
      _navigationHandled = true;
      context.go(AppRoutes.sheetSelection);
    } else if (state is SheetConnected) {
      _navigationHandled = true;
      context.go(AppRoutes.menuprincipal);
    } else if (state is SheetDisconnected || state is SheetError) {
      _navigationHandled = true;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<GoogleSheetCubit, SheetState>(
        listener: (context, state) => _handleNavigation(state),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Image.asset(
                  'assets/images/splash1.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Color(0xFF1E3A8A),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initialisation...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

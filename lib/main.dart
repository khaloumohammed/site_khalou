// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:attendance_app/injection_container.dart';
import 'package:attendance_app/config/app_router.dart';
import 'package:attendance_app/core/theme/app_theme.dart';

// BLoCs
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/classes/class_cubit.dart';
import 'package:attendance_app/presentation/seances/seances_cubit.dart';
import 'package:attendance_app/presentation/items/item_cubit.dart';
import 'package:attendance_app/presentation/eleves/eleve_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const AttendanceApp());
}

/// Application principale avec gestion d'état globale via BLoC
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _buildBlocProviders(),
      child: MaterialApp.router(
        title: 'Attendance App',
        theme: _buildTheme(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Construit la liste des BLoCs globaux
  static List<BlocProvider> _buildBlocProviders() {
    final getIt = GetIt.instance;
    return [
      BlocProvider<GoogleSheetCubit>(create: (_) => getIt<GoogleSheetCubit>()),
      BlocProvider<ClassCubit>(create: (_) => getIt<ClassCubit>()),
      BlocProvider<SessionCubit>(create: (_) => getIt<SessionCubit>()),
      BlocProvider<ItemCubit>(create: (_) => getIt<ItemCubit>()),
      BlocProvider<ElevesCubit>(create: (_) => getIt<ElevesCubit>()),
    ];
  }

  /// Construit le thème de l'application
  static ThemeData _buildTheme() {
    return AppTheme.lightTheme;
  }
}

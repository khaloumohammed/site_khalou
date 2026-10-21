// lib/injection_container.dart

import 'package:get_it/get_it.dart';

// Services
import 'package:attendance_app/core/services/auth_service.dart';
import 'package:attendance_app/core/services/eleves_service.dart';
import 'package:attendance_app/core/services/seances_service.dart';
import 'package:attendance_app/core/services/criteres_service.dart';

// Data Sources & Repositories
import 'package:attendance_app/data/datasources/google_sheets_data_source.dart';
import 'package:attendance_app/data/repositories/item_repository_impl.dart';
import 'package:attendance_app/data/repositories/eleve_repository_impl.dart';

// Domain
import 'package:attendance_app/domain/repositories/item_repository.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';
import 'package:attendance_app/domain/usecases/item/create_item.dart';
import 'package:attendance_app/domain/usecases/item/update_item.dart';
import 'package:attendance_app/domain/usecases/item/delete_item.dart';
import 'package:attendance_app/domain/usecases/item/get_items.dart';
import 'package:attendance_app/domain/usecases/eleve/create_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/update_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/delete_eleve.dart';
import 'package:attendance_app/domain/usecases/eleve/update_numeros_en_masse.dart';
import 'package:attendance_app/domain/usecases/eleve/get_eleves.dart';

// Cubits
import 'package:attendance_app/presentation/classes/class_cubit.dart';
import 'package:attendance_app/presentation/home/google_sheet_cubit.dart';
import 'package:attendance_app/presentation/items/item_cubit.dart';
import 'package:attendance_app/presentation/seances/seances_cubit.dart';
import 'package:attendance_app/presentation/eleves/eleve_cubit.dart';

final sl = GetIt.instance;

/// Initialise toutes les dépendances de l'application
Future<void> setupDependencies() async {
  // ===================================
  // 1. SERVICES & DATA SOURCES
  // ===================================
  sl.registerLazySingleton<AuthService>(() => AuthService());

  sl.registerLazySingleton<GoogleSheetsDataSource>(
    () => GoogleSheetsDataSource(sl<AuthService>()),
  );

  sl.registerLazySingleton<ElevesService>(
    () => ElevesService(sl<AuthService>()),
  );

  sl.registerLazySingleton<SeancesService>(
    () => SeancesService(sl<AuthService>()),
  );

  sl.registerLazySingleton<CriteresService>(
    () => CriteresService(sl<AuthService>()),
  );

  // ===================================
  // 2. REPOSITORIES
  // ===================================
  sl.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(sl<CriteresService>()),
  );

  sl.registerLazySingleton<EleveRepository>(
    () => EleveRepositoryImpl(sl<ElevesService>()),
  );

  // ===================================
  // 3. USE CASES - ITEMS
  // ===================================
  sl.registerLazySingleton<GetItems>(() => GetItems(sl()));
  sl.registerLazySingleton<CreateItem>(() => CreateItem(sl()));
  sl.registerLazySingleton<UpdateItem>(() => UpdateItem(sl()));
  sl.registerLazySingleton<DeleteItem>(() => DeleteItem(sl()));

  // ===================================
  // 4. USE CASES - ELEVES
  // ===================================
  sl.registerLazySingleton<GetEleves>(() => GetEleves(sl()));
  sl.registerLazySingleton<CreateEleve>(() => CreateEleve(sl()));
  sl.registerLazySingleton<UpdateEleve>(() => UpdateEleve(sl()));
  sl.registerLazySingleton<DeleteEleve>(() => DeleteEleve(sl()));
  sl.registerLazySingleton<UpdateNumerosEnMasse>(
    () => UpdateNumerosEnMasse(sl()),
  );

  // ===================================
  // 5. PRESENTATION (Cubits)
  // ===================================
  sl.registerSingleton<GoogleSheetCubit>(
    GoogleSheetCubit(
      sl<GoogleSheetsDataSource>(),
      sl<AuthService>(),
      sl<ElevesService>(),
      sl<SeancesService>(),
      sl<CriteresService>(),
    ),
  );

  sl.registerFactory<ClassCubit>(
    () => ClassCubit(
      elevesService: sl<ElevesService>(),
      authService: sl<AuthService>(),
    ),
  );

  sl.registerFactory<SessionCubit>(
    () => SessionCubit(seancesService: sl<SeancesService>()),
  );

  sl.registerFactory<ItemCubit>(
    () => ItemCubit(
      getItems: sl<GetItems>(),
      createItem: sl<CreateItem>(),
      updateItem: sl<UpdateItem>(),
      deleteItem: sl<DeleteItem>(),
    ),
  );

  sl.registerFactory<ElevesCubit>(
    () => ElevesCubit(
      getElevesUsecase: sl<GetEleves>(),
      createEleveUsecase: sl<CreateEleve>(),
      updateEleveUsecase: sl<UpdateEleve>(),
      deleteEleveUsecase: sl<DeleteEleve>(),
      updateNumerosUsecase: sl<UpdateNumerosEnMasse>(),
    ),
  );
}

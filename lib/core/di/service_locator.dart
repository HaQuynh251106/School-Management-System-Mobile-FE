import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../network/realtime_service.dart';
import '../storage/token_storage.dart';
import '../theme/theme_controller.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<ThemeController>(() => ThemeController(sl()));
  await sl<ThemeController>().load();

  // Network
  sl.registerLazySingleton<Dio>(() => createDioClient(sl()));
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));
  sl.registerLazySingleton<RealtimeService>(() => RealtimeService(sl()));

  // Auth
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(api: sl(), storage: sl()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(repository: sl(), realtime: sl()),
  );
}

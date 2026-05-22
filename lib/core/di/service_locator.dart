import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Storage
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));

  // Network
  sl.registerLazySingleton<Dio>(() => createDioClient(sl()));

  // Auth
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(api: sl(), storage: sl()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(repository: sl()));
}

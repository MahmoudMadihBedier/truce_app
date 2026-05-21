import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../services/guest_service.dart';
import '../theme/settings_cubit.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/datasources/product_remote_datasource_impl.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_all_products.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/search_products.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/products/presentation/cubit/product_cubit.dart';
import '../../features/products/presentation/cubit/search_cubit.dart';
import '../../features/market/domain/repositories/market_repository.dart';
import '../../features/market/data/repositories/market_repository_impl.dart';
import '../../features/market/data/datasources/market_remote_data_source.dart';
import '../../features/market/data/datasources/market_remote_data_source_impl.dart';
import '../../features/market/domain/usecases/get_market_rates.dart';
import '../../features/market/domain/usecases/get_market_details.dart';
import '../../features/market/presentation/cubit/market_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);

  sl.registerLazySingleton(() => Dio(BaseOptions(
    baseUrl: 'https://truce-ap-is-dw59.vercel.app',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )));
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => GuestService(sl()));
  sl.registerFactory(() => SettingsCubit(sl()));

  // Features - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerFactory(() => AuthCubit(sl()));

  // Features - Products
  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  sl.registerFactory(
    () => ProductCubit(
      getAllProducts: sl(),
      getProducts: sl(),
    ),
  );
  sl.registerFactory(() => SearchCubit(sl()));

  // Features - Market
  sl.registerLazySingleton<MarketRemoteDataSource>(() => MarketRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MarketRepository>(() => MarketRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetMarketRates(sl()));
  sl.registerLazySingleton(() => GetMarketDetails(sl()));
  sl.registerFactory(() => MarketCubit(getMarketRates: sl(), getMarketDetails: sl()));
}

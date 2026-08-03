import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';

// core
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/network/dio_client.dart';
import 'package:bobo/features/splash/splash_screen.dart';

// auth
import 'package:bobo/features/auth/domain/repositories/auth_repository.dart';
import 'package:bobo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bobo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_cubit.dart';

// profile
import 'package:bobo/features/profile/domain/repositories/profile_repository.dart';
import 'package:bobo/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bobo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bobo/features/profile/presentation/cubit/user_cubit.dart';

// home
import 'package:bobo/features/home/domain/repositories/home_repository.dart';
import 'package:bobo/features/home/data/datasources/home_remote_data_source.dart';
import 'package:bobo/features/home/data/repositories/home_repository_impl.dart';
import 'package:bobo/features/home/presentation/cubit/home_cubit.dart';
import 'package:bobo/features/home/presentation/cubit/product_cubit.dart';

// favorite
import 'package:bobo/features/favorite/presentation/cubit/favorite_cubit.dart';

// cart
import 'package:bobo/features/cart/domain/repositories/cart_repository.dart';
import 'package:bobo/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:bobo/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:bobo/features/cart/presentation/cubit/cart_cubit.dart';

// orders
import 'package:bobo/features/orders/domain/repositories/order_repository.dart';
import 'package:bobo/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:bobo/features/orders/data/repositories/order_repository_impl.dart';
import 'package:bobo/features/orders/presentation/cubit/order_cubit.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Instantiate Dio
      final dio = DioClient().dio;

      // Instantiate Repositories
      final authRepository = AuthRepositoryImpl(AuthRemoteDataSource(dio));
      final profileRepository = ProfileRepositoryImpl(ProfileRemoteDataSource(dio));
      final homeRepository = HomeRepositoryImpl(HomeRemoteDataSource(dio));
      final cartRepository = CartRepositoryImpl(CartRemoteDataSource(dio));
      final orderRepository = OrderRepositoryImpl(OrderRemoteDataSource(dio));

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>.value(value: authRepository),
            RepositoryProvider<ProfileRepository>.value(value: profileRepository),
            RepositoryProvider<HomeRepository>.value(value: homeRepository),
            RepositoryProvider<CartRepository>.value(value: cartRepository),
            RepositoryProvider<OrderRepository>.value(value: orderRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AuthCubit(authRepository)..checkAuthStatus(),
              ),
              BlocProvider(
                create: (context) => UserCubit(profileRepository, authRepository)..fetchUser(),
              ),
              BlocProvider(
                create: (context) => HomeCubit(homeRepository)..loadHomeData(),
              ),
              BlocProvider(
                create: (context) => ProductCubit(homeRepository: homeRepository)..loadProducts(),
              ),
              BlocProvider(
                create: (context) => FavoriteCubit(),
              ),
              BlocProvider(
                create: (context) => CartCubit(cartRepository, authRepository),
              ),
              BlocProvider(
                create: (context) => OrderCubit(orderRepository: orderRepository),
              ),
            ],
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('Error: $error\n$stackTrace');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return OverlaySupport.global(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bobo App',

            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.lightGrey0,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.lightPrimary600,
                primary: AppColors.lightPrimary600,
                secondary: AppColors.lightPrimary200,
                surface: AppColors.lightGrey0,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightGrey0,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.darkGrey0,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.darkPrimary600,
                primary: AppColors.darkPrimary600,
                secondary: AppColors.darkPrimary200,
                surface: AppColors.darkGrey0,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkGrey0,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),

            themeMode: ThemeMode.system,

            // الصفحة الأولى
            home: const SplashScreen(),

            // navigation routes
            onGenerateRoute: AppRoutes.generateRoute,

            // Error UI
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Scaffold(
                  appBar: AppBar(title: const Text('حدث خطأ')),

                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'عذراً، حدث خطأ غير متوقع. الرجاء إعادة تشغيل التطبيق.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                );
              };
              return child!;
            },
          ),
        );
      },
    );
  }
}

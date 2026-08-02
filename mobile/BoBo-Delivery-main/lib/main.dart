import 'dart:async';
import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/controller/favorite/cubit/favorite_cubit.dart';
import 'package:bobo/controller/user/cubit/user_cubit.dart';
import 'package:bobo/controller/user/repository/user_repository.dart';
import 'package:bobo/controller/product/cubit/product_cubit.dart';
import 'package:bobo/controller/product/repository/product_repository.dart';
import 'package:bobo/controller/order/cubit/order_cubit.dart';
import 'package:bobo/controller/order/repository/order_repository.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => CartCubit()),
            BlocProvider(create: (context) => FavoriteCubit()),
            BlocProvider(create: (context) => UserCubit(UserRepository())..fetchUser()),
            BlocProvider(create: (context) => ProductCubit(productRepository: ProductRepository())..loadProducts()),
            BlocProvider(create: (context) => OrderCubit(orderRepository: OrderRepository())),
          ],
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('Errorrrrrrrrrrr $error\n$stackTrace');
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

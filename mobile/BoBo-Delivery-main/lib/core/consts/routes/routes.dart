import 'package:bobo/core/components/not_found_screen.dart';
import 'package:bobo/features/auth/otp/verify_otp_new_account.dart';
import 'package:bobo/features/auth/forgetpassword/pages/verify_otp_page.dart';
import 'package:bobo/features/auth/login/pages/login_page_screen.dart';
import 'package:bobo/features/auth/reset_password/pages/reset_password_screen.dart';
import 'package:bobo/features/auth/signup/pages/create_account_screen.dart';
import 'package:bobo/features/cart/screen/changeAddress/change_address.dart';
import 'package:bobo/features/cart/screen/changeCard/change_card.dart';
import 'package:bobo/features/cart/screen/check_address_screen.dart';
import 'package:bobo/features/cart/screen/checkout/checkout_screen.dart';
import 'package:bobo/features/cart/screen/coupon/add_coupone.dart';
import 'package:bobo/features/cart/screen/order_submitted.dart';
import 'package:bobo/features/cart/screen/place_order_screen.dart';
import 'package:bobo/features/discover_page/pages/discover_screen.dart';
import 'package:bobo/features/favorate/pages/favorate_screen.dart';

import 'package:bobo/features/home/pages/main_nav_screen.dart';
import 'package:bobo/features/my_orders/pages/my_orders_screen.dart';
import 'package:bobo/features/products_details/pages/product_detail_screen.dart';
import 'package:bobo/features/on_board/pages/on_board_page.dart';
import 'package:bobo/features/on_board/pages/on_boarding_auth.dart';
import 'package:bobo/features/profile/pages/create_profile_screen.dart';
import 'package:bobo/features/profile/pages/my_account/my_account_screen.dart';
import 'package:bobo/features/profile/pages/payment_methods/payment_methods_screen.dart';
import 'package:bobo/features/profile/pages/payment_methods/add_card_screen.dart';
import 'package:bobo/features/profile/pages/addresses/addresses_screen.dart';
import 'package:bobo/features/profile/pages/addresses/add_address_screen.dart';
import 'package:bobo/features/profile/pages/settings/settings_screen.dart';
import 'package:bobo/features/profile/pages/settings/language_screen.dart';
import 'package:bobo/features/profile/pages/user_profile.dart';
import 'package:bobo/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String mainNav = '/main';
  static const String onBoarding = '/onBoarding';
  static const String onBoardingAuth = '/onBoardingAuth';
  static const String profile = '/profile';
  static const String loginscreen = '/loginscreen';
  static const String verifyOtpScreen = '/verifyOtp';
  static const String verifyOtpScreenNewAccount = '/verifyOtpNewAccount';
  static const String notfoundpage = '/notfoundpage';
  static const String resetpassword = '/resetpassword';
  static const String createAccount = '/createAccount';
  static const String createProfileScreen = '/createProfileScreen';
  static const String homePage = '/homepage';
  static const String productDetailScreen = '/productDetailScreen';
  static const String checkAddressScreen = '/checkAddressScreen';
  static const String orderSubmitted = '/orderSubmittedScreen';
  static const String userProfileScreen = '/userProfileScreen';
  static const String myOrdersScreen = '/myOrdersScreen';
  static const String discoverScreen = '/discoverScreen';
  static const String favorateScreen = '/favorateScreen';
  static const String palceOrderScreen = '/palceOrderScreen';
  static const String addCoupone = '/addCouponeScreen';
  static const String checkoutScreen = '/checkoutScreen';
  static const String changeAddress = '/changeAddressScreen';
  static const String changeCard = '/changeCardScreen';
  static const String myAccountScreen = '/myAccountScreen';
  static const String paymentMethods = '/paymentMethodsScreen';
  static const String addCard = '/addCardScreen';
  static const String addresses = '/addressesScreen';
  static const String addAddress = '/addAddressScreen';
  static const String settings = '/settingsScreen';
  static const String language = '/languageScreen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case mainNav:
      case homePage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavScreen(),
        );

      case onBoarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnBoardPage(),
        );

      case onBoardingAuth:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnBoardingAuth(),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Profile Page"))),
        );
      case loginscreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPageScreen(),
        );
      case verifyOtpScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VerifyOtpScreen(),
        );
      case notfoundpage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotFoundScreen(),
        );
      case resetpassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResetPasswordScreen(),
        );
      case createAccount:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateAccountScreen(),
        );
      case verifyOtpScreenNewAccount:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VerifyOtpNewAccountScreen(),
        );
      case createProfileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateProfileScreen(),
        );
      case productDetailScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProductDetailScreen(),
        );
      case checkAddressScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CheckAddressScreen(),
        );
      case orderSubmitted:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrderSubmitted(),
        );
      case myOrdersScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyOrdersScreen(),
        );
      case userProfileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UserProfileScreen(),
        );
      case discoverScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DiscoverScreen(),
        );
      case favorateScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FavorateScreen(),
        );
      case palceOrderScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceOrderScreen(),
        );
      case addCoupone:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddCoupone(),
        );
      case checkoutScreen:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
        );
      case changeAddress:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChangeAddress(),
        );
      case changeCard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChangeCardScreen(),
        );
      case myAccountScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyAccountScreen(),
        );
      case paymentMethods:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PaymentMethodsScreen(),
        );
      case addCard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddCardScreen(),
        );
      case addresses:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddressesScreen(),
        );
      case addAddress:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddAddressScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );
      case language:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LanguageScreen(),
        );

      //==============================================================================
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}

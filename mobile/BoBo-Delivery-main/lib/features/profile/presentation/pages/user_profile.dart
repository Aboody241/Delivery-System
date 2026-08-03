import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/features/profile/presentation/widgets/dark_mode_widget.dart';
import 'package:bobo/features/profile/presentation/widgets/general_setting_widget.dart';
import 'package:bobo/features/profile/presentation/widgets/user_information_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:bobo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_state.dart';
import 'package:bobo/core/consts/widgets/guest_access_placeholder.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CenterWidgetAppbar(
          title: Text('My Profile', style: AppTextStyle.poppins24Bold),
        ),
      ),

      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLoggedIn = state is AuthAuthenticated;
          if (!isLoggedIn) {
            return const GuestAccessPlaceholder(
              title: 'Login Required',
              description: 'Please log in or register to view your account details and profile settings.',
              icon: Icons.person_outline_rounded,
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //    Text('My Profile', style: AppTextStyle.poppins24Bold)
            // ],),
            GestureDetector(onTap: () {}, child: UserInformationWidget()),

            Gap(30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General',
                    style: AppTextStyle.poppins18Bold.copyWith(
                      color: AppColors.darkGrey300,
                    ),
                  ),
                  SizedBox(height: 550, child: GeneralSettingWidget()),

                  Text(
                    'Theme',
                    style: AppTextStyle.poppins18Bold.copyWith(
                      color: AppColors.darkGrey300,
                    ),
                  ),
                  DarkModeWidget(),
                ],
              ),
            ),
            Gap(20),
          ],
        ),
      );
    },
  ),
);
  }
}

import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/features/profile/widgets/dark_mode_widget.dart';
import 'package:bobo/features/profile/widgets/general_setting_widget.dart';
import 'package:bobo/features/profile/widgets/user_information_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
        preferredSize: Size.fromHeight(60),
        child: CenterWidgetAppbar(
          title: Text('My Profile', style: AppTextStyle.poppins24Bold),
        ),
      ),

      body: SingleChildScrollView(
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
      ),
    );
  }
}

import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset('assets/consts/notfound.png'),
            ),
            Gap(40),
            Text(
              'Sorry, Page Not Found!',
              style: AppTextStyle.poppins30.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(10),
            Text(
              'you can back to the previos page, \nwill be shown here as well.',
              style: AppTextStyle.poppins14.copyWith(
                color: AppColors.darkGrey400,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(100),
          ],
        ),
      ),
    );
  }
}

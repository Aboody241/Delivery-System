import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class GuestAccessPlaceholder extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const GuestAccessPlaceholder({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.lock_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary500.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 72,
                color: AppColors.lightPrimary500,
              ),
            ),
            const Gap(32),
            Text(
              title,
              style: AppTextStyle.poppins24Bold.copyWith(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              description,
              style: AppTextStyle.poppins14.copyWith(
                color: AppColors.darkGrey300,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(48),
            CustomButton2(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(AppRoutes.loginscreen);
              },
              title: 'Log In or Sign Up',
              hei: 56,
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

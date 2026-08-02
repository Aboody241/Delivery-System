import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/button_style.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isvalidate = false;

  void validator() {
    setState(() {
      isvalidate =
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text &&
          passwordController.text.length > 5;
    });
  }

  @override
  void initState() {
    passwordController.addListener(validator);
    confirmPasswordController.addListener(validator);
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitledText(title: 'Create a new password'),
            Gap(15),
            Text(
              'Enter a new password and try not to forget it.',
              style: AppTextStyle.poppins14.copyWith(
                color: AppColors.darkGrey300,
              ),
            ),
            Gap(30),
            Passwordfields(
              controller: passwordController,
              hintText: 'Password',
            ),
            Gap(15),
            Passwordfields(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
            ),
            Spacer(),
            EnabledButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainNav,
                  (route) => false,
                );
              },
              hei: 55,
              child: Text('Confirm', style: ButtonTextStyle.button),
            ),
            Gap(50),
          ],
        ),
      ),
    );
  }
}

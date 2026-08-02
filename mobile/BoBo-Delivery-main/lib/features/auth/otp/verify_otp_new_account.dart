import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/titled_text.dart';
import 'package:bobo/features/profile/pages/create_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:gap/gap.dart';

class VerifyOtpNewAccountScreen extends StatefulWidget {
  const VerifyOtpNewAccountScreen({super.key});

  @override
  State<VerifyOtpNewAccountScreen> createState() =>
      _VerifyOtpNewAccountScreenState();
}

class _VerifyOtpNewAccountScreenState extends State<VerifyOtpNewAccountScreen> {
  void _showSuccesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.darkGradientLight,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text('Success Process', style: AppTextStyle.poppins16),
              const SizedBox(height: 8),
              const Text(
                'You Account Created, Now Init Your Profile',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(context).pop();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
      );
    });
  }

  String currentOtp = "";
  bool isOtpComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CenterLogoAndBackAppbar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitledText(title: 'Verify OTP Code'),
            const Gap(12),
            Text(
              'Enter the verification code sent to your email sample@example.com',
              style: AppTextStyle.poppinsMedium400.copyWith(
                color: AppColors.darkGrey200,
              ),
            ),
            const Gap(50),

            OtpTextField(
              fieldWidth: 55,
              numberOfFields: 4,
              borderColor: AppColors.black,
              focusedBorderColor: AppColors.darkGradientLight,
              showFieldAsBox: true,
              onCodeChanged: (String code) {
                setState(() {
                  currentOtp = code;
                  isOtpComplete = code.length == 4; // لو اتملأت الأربع خانات
                });
              },
              onSubmit: (String verificationCode) {
                _showSuccesDialog();
              },
            ),

            const Gap(20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn’t received the code?  ',
                  style: AppTextStyle.poppins14,
                ),
                Text('00:00', style: AppTextStyle.poppinsLarge),
                TextButton(
                  onPressed: () {},
                  child: Text('Resent', style: AppTextStyle.poppins16Bold),
                ),
              ],
            ),

            const Spacer(),

            EnabledButton(
              onPressed: isOtpComplete ? _showSuccesDialog : null,
              hei: 55,
              child: Text('Verify'),
            ),

            const Gap(50),
          ],
        ),
      ),
    );
  }
}

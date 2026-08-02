
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DarkModeWidget extends StatelessWidget {
  const DarkModeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color.fromARGB(255, 243, 245, 241),
      ),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode_outlined,
            color: AppColors.darkGrey200,
            size: 28,
          ),
          Gap(20),
          Text(
            'Dark Mode',
            style: AppTextStyle.poppins18.copyWith(
              color: AppColors.darkGrey200,
            ),
          ),
          Spacer(),
          Switch(
            value: false,
            onChanged: (ontab) {},
            inactiveThumbColor: AppColors.darkGrey400,
          ),
        ],
      ),
    );
  }
}

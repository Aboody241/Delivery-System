import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';

class TitledText extends StatelessWidget {
  const TitledText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyle.poppinsHeading1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

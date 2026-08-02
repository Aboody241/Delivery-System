import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';

class OnBoardModel {
  final String image;
  final String title;
  final String subtitle;

  OnBoardModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

final List<OnBoardModel> onboardData = [
  OnBoardModel(
    image: "assets/on_board/onb1.png",
    title: "Welcome to the \nmost tastiest app",
    subtitle: "You know, this app is edible meaning you can eat it!",
  ),
  OnBoardModel(
    image: "assets/on_board/onb2.png",
    title: "We use nitro on bicycles for delivery!",
    subtitle:
        "For very fast delivery we use nitro on bicycles, kidding, but we’re very fast.",
  ),
  OnBoardModel(
    image: "assets/on_board/onb3.png",
    title: "We’re the besties of birthday peoples",
    subtitle: "We send cakes to our plus members (one cake per person).",
  ),
];

/// ------------------------------
/// Widget واحد فقط + نظيف
/// ------------------------------
class OnBoardItem extends StatelessWidget {
  final OnBoardModel model;

  const OnBoardItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: Image.asset(model.image)),
          const SizedBox(height: 24),
          Text(
            model.title,
            textAlign: TextAlign.center,
            style: AppTextStyle.poppinsHeading1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            model.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.poppins20.copyWith(
              color: AppColors.lightTypography300,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// ------------------------------
/// بديل لـ Onboard1 / 2 / 3
/// ------------------------------
class Onboard1 extends StatelessWidget {
  const Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardItem(model: onboardData[0]);
  }
}

class Onboard2 extends StatelessWidget {
  const Onboard2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardItem(model: onboardData[1]);
  }
}

class Onboard3 extends StatelessWidget {
  const Onboard3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardItem(model: onboardData[2]);
  }
}

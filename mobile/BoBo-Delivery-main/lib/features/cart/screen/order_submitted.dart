import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OrderSubmitted extends StatelessWidget {
  const OrderSubmitted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(300),
            Image.asset(
              'assets/consts/submit_order.png',
              width: 400,
              height: 200,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        child: CustomButton2(
          title: 'Back to Home',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              AppRoutes.mainNav,
              (route) => false,
            );
          },
          hei: 60,
        ),
      ),
    );
  }
}

import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 16,
          ),
          label: Text(
            'Back',
            style: AppTextStyle.poppins16Bold.copyWith(color: Colors.black),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Payment Methods",
          style: AppTextStyle.poppins20Bold.copyWith(color: AppColors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addCard);
            },
            icon: const Icon(Icons.add, color: Colors.black, size: 26),
          ),
          const Gap(10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Default Section Header
            Text(
              'Default',
              style: AppTextStyle.poppins14Bold.copyWith(
                color: AppColors.darkGrey300,
              ),
            ),
            const Gap(12),

            // Default card option
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.changeCard);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.back,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mastercard - Daniel Jones',
                        style: AppTextStyle.poppins16.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.darkGrey400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(25),

            // Section Divider
            const Divider(color: Color(0xFFECECEC), thickness: 1),
            const Gap(25),

            // Others Section Header
            Text(
              'Others',
              style: AppTextStyle.poppins14Bold.copyWith(
                color: AppColors.darkGrey300,
              ),
            ),
            const Gap(12),

            // Others card option
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.changeCard);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.back,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mastercard - Emily Jones',
                        style: AppTextStyle.poppins16.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.darkGrey400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

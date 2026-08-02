import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckAddressScreen extends StatelessWidget {
  const CheckAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterChildAndBackAppbar(
          title: Text('Check Address', style: AppTextStyle.poppins22Bold),
          leading: CustomBackButton(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              BasicTextField(
                hintText: 'Address',
                suffix: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.place, color: AppColors.darkGrey300),
                ),
              ),
              Gap(500),
              CustomButton2(
                title: 'Submit Order',
                onPressed: () {
                  context.read<CartCubit>().clearCart();
                  Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(AppRoutes.orderSubmitted);
                },
                hei: 60,
              ),
            ],
          ),
        ),
      ),

      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      //   child: ,
      // ),
    );
  }
}

import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bobo/features/cart/data/models/cart_class.dart';
import 'package:bobo/features/cart/presentation/widgets/produt_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:bobo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bobo/features/auth/presentation/cubit/auth_state.dart';
import 'package:bobo/core/consts/widgets/guest_access_placeholder.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = state is AuthAuthenticated;
        if (!isLoggedIn) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: CenterWidgetAppbar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/cart_icon.svg',
                      width: 40,
                      height: 40,
                    ),
                    Text('Cart', style: AppTextStyle.poppins22Bold),
                  ],
                ),
              ),
            ),
            body: const GuestAccessPlaceholder(
              title: 'Login Required',
              description: 'Please log in or register to view and manage your shopping cart.',
              icon: Icons.shopping_cart_outlined,
            ),
          );
        }

        return BlocBuilder<CartCubit, List<CartItem>>(
          builder: (context, cartItems) {
            double totalPrice = cartItems.fold(
              0,
              (sum, item) => sum + (item.price * item.quantity),
            );

            return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CenterWidgetAppbar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/cart_icon.svg',
                    width: 40,
                    height: 40,
                  ),
                  Text('Cart', style: AppTextStyle.poppins22Bold),
                ],
              ),
            ),
          ),
          body: cartItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(19),
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
                          'There is no Products\n in the Cart!',
                          style: AppTextStyle.poppins30.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(10),
                        Text(
                          'You can Discover More Products \nwe will be shown here as well.',
                          style: AppTextStyle.poppins14.copyWith(
                            color: AppColors.darkGrey400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(100),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: cartItems.length,
                        (context, index) {
                          final product = cartItems[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ProdutCartItem(
                              productName: product.title,
                              price: product.price,
                              quantity: product.quantity,
                              imageUrl: product.imageUrl,
                              onAdd: () {
                                context.read<CartCubit>().addItem(product);
                              },
                              onRemove: () {
                                context.read<CartCubit>().decrementItem(
                                  product.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: cartItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: CustomButton2(
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(AppRoutes.mainNav);
                    },
                    title: 'Discover More Products',
                    hei: 60,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyle.poppins20Bold,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: CustomButton2(
                          onPressed: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(AppRoutes.palceOrderScreen);
                          },
                          title: 'Proceed to  Pay',
                          hei: 60,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  },
);
  }
}
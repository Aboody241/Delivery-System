import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:bobo/features/cart/widgets/produt_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, List<CartItem>>(
      builder: (context, cartItems) {
        double subtotal = cartItems.fold(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        double deliveryCharges = cartItems.isEmpty ? 0.0 : 3.99;

        double total = subtotal + deliveryCharges;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CenterChildAndBackAppbar(
              title: Text('Place Order', style: AppTextStyle.poppins22Bold),
              leading: CustomBackButton(),
            ),
          ),
          body: cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.asset('assets/consts/notfound.png'),
                      ),
                      const Gap(40),
                      Text(
                        'There is no Products in the Cart!',
                        style: AppTextStyle.poppins30.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(10),
                      Text(
                        'You can Discover More Products \nwe will be shown here as well.',
                        style: AppTextStyle.poppins14.copyWith(
                          color: AppColors.darkGrey400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(100),
                    ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    const SliverToBoxAdapter(child: SizedBox.shrink()),

                    const SliverToBoxAdapter(child: Gap(25)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Delivery Charges',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '+\$${deliveryCharges.toStringAsFixed(2)}',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const Gap(10),
                            const Divider(
                              color: Color.fromARGB(255, 230, 230, 230),
                              thickness: 1,
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: AppTextStyle.poppins18Bold.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: AppTextStyle.poppins18Bold.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Gap(40)),
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
              : Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    top: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '\$ ${total.toStringAsFixed(2)}',
                          style: AppTextStyle.poppins22Bold.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: CustomButton2(
                          onPressed: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRoutes.checkoutScreen,
                              arguments: _selectedCoupon,
                            );
                          },
                          title: 'Continue',
                          hei: 60,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

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
  String? _selectedCoupon = 'WELCOME50';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, List<CartItem>>(
      builder: (context, cartItems) {
        double subtotal = cartItems.fold(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        double deliveryCharges = cartItems.isEmpty ? 0.0 : 3.99;
        
        double discount = 0.0;
        if (_selectedCoupon != null) {
          if (_selectedCoupon == 'WELCOME50') {
            discount = subtotal * 0.5;
          } else if (_selectedCoupon == 'EXTRA20' && subtotal > 30) {
            discount = subtotal * 0.2;
          } else if (_selectedCoupon == 'WEEKEND5' && subtotal > 25) {
            discount = 5.0;
          } else if (_selectedCoupon == 'PIZZA10') {
            discount = subtotal * 0.1;
          }
        }

        double total = subtotal + deliveryCharges - discount;

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
                    const SliverToBoxAdapter(child: Gap(20)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.addCoupone,
                              arguments: _selectedCoupon,
                            );
                            if (result != null && result is String) {
                              setState(() {
                                _selectedCoupon = result;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAF8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFECECEC),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.confirmation_num_outlined,
                                  color: AppColors.lightTypography200,
                                  size: 24,
                                ),
                                const Gap(16),
                                Expanded(
                                  child: _selectedCoupon != null
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'COUPON',
                                              style: AppTextStyle.poppins12.copyWith(
                                                color: AppColors.lightTypography200,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const Gap(2),
                                            Text(
                                              _selectedCoupon!,
                                              style: AppTextStyle.poppins16Bold.copyWith(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Add a coupon',
                                          style: AppTextStyle.poppins14.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.lightTypography200,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

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
                            if (discount > 0) ...[
                              const Gap(12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount ($_selectedCoupon)',
                                    style: AppTextStyle.poppins16.copyWith(
                                      color: AppColors.lightPrimary500,
                                    ),
                                  ),
                                  Text(
                                    '-\$${discount.toStringAsFixed(2)}',
                                    style: AppTextStyle.poppins16.copyWith(
                                      color: AppColors.lightPrimary500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

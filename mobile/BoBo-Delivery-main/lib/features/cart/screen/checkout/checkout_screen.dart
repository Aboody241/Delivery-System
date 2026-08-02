import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:bobo/controller/order/cubit/order_cubit.dart';
import 'package:bobo/controller/order/cubit/order_state.dart';
import 'package:bobo/controller/order/models/order_model.dart';
import 'package:bobo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String userId = 'guest';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await AuthService().getCurrentUserUid() ?? 'guest';
    if (mounted) {
      setState(() {
        userId = uid;
      });
    }
  }

  String? _selectedCoupon;
  bool _isInitialized = false;
  Map<String, String> _selectedAddress = {
    'title': 'Home',
    'address': 'Home - 123 Main St, Apt 4B',
  };
  Map<String, String> _selectedCard = {
    'title': 'Mastercard - Daniel Jones',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _selectedCoupon = args;
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, List<CartItem>>(
      builder: (context, cartItems) {
        double subtotal = cartItems.fold(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        double deliveryCharges = cartItems.isEmpty ? 0.0 : 3.99;

        // Calculate Discount
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
        if (total < 0) total = 0;

        return BlocConsumer<OrderCubit, OrderState>(
          listener: (context, orderState) {
            if (orderState is OrderPlaceSuccess) {
              context.read<CartCubit>().clearCart();
              Navigator.of(context, rootNavigator: true).pushReplacementNamed(AppRoutes.orderSubmitted);
            } else if (orderState is OrderPlaceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(orderState.message)),
              );
            }
          },
          builder: (context, orderState) {
            final isPlacingOrder = orderState is OrderPlaceLoading;
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
              "Checkout",
              style: AppTextStyle.poppins20Bold.copyWith(color: Colors.black),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: Gap(15)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      // Deliver To Card
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.changeAddress,
                            arguments: _selectedAddress['title'],
                          );
                          if (result != null && result is Map<String, String>) {
                            setState(() {
                              _selectedAddress = result;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.back,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 26,
                                color: AppColors.darkGrey400,
                              ),
                              const Gap(15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deliver to',
                                      style: AppTextStyle.poppins14.copyWith(
                                        color: AppColors.darkGrey300,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Gap(2),
                                    Text(
                                      _selectedAddress['address']!,
                                      style: AppTextStyle.poppins16.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
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
                      const Gap(15),

                      // Payment From Card
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.changeCard,
                            arguments: _selectedCard['title'],
                          );
                          if (result != null && result is Map<String, String>) {
                            setState(() {
                              _selectedCard = result;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.back,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.credit_card_outlined,
                                size: 26,
                                color: AppColors.darkGrey400,
                              ),
                              const Gap(15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment from',
                                      style: AppTextStyle.poppins14.copyWith(
                                        color: AppColors.darkGrey300,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Gap(2),
                                    Text(
                                      _selectedCard['title']!,
                                      style: AppTextStyle.poppins16.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
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
                      const Gap(30),

                      // Receipt Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  subtotal.toStringAsFixed(2),
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (discount > 0) ...[
                              const Gap(14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Coupon',
                                    style: AppTextStyle.poppins16.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '-${discount.toStringAsFixed(1)}',
                                    style: AppTextStyle.poppins16.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const Gap(14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Delivery Charges',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '+${deliveryCharges.toStringAsFixed(2)}',
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            const Divider(
                              color: Color(0xFFECECEC),
                              thickness: 1,
                            ),
                            const Gap(16),
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
                                  total.toStringAsFixed(2),
                                  style: AppTextStyle.poppins18Bold.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
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
                  flex: 3,
                  child: Text(
                    '\$ ${total.toStringAsFixed(2)}',
                    style: AppTextStyle.poppins24Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    onTap: isPlacingOrder
                        ? null
                        : () {
                            if (cartItems.isEmpty) return;
                            final order = OrderModel(
                              orderId: '',
                              userId: userId,
                              items: cartItems.map((c) => OrderItem(
                                productId: c.id,
                                name: c.title,
                                price: c.price.toString(),
                                quantity: c.quantity.toString(),
                                imageUrl: c.imageUrl,
                              )).toList(),
                              total: total.toStringAsFixed(2),
                              status: 'pending',
                              createdAt: DateTime.now(),
                            );
                            context.read<OrderCubit>().placeOrder(order);
                          },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isPlacingOrder
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Place order',
                                style: AppTextStyle.poppins16Bold.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
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

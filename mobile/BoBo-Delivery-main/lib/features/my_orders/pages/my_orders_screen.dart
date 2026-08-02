import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/controller/order/cubit/order_cubit.dart';
import 'package:bobo/controller/order/cubit/order_state.dart';
import 'package:bobo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userId = await AuthService().getCurrentUserUid() ?? 'guest';
    if (mounted) {
      context.read<OrderCubit>().fetchUserOrders(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: CenterChildAndBackAppbar(
            title: Text('My Orders', style: AppTextStyle.poppins24Bold),
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_sharp),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF3F5F1,
                  ), // Bobo App signature background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  padding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xFF2A2A2A),
                  unselectedLabelColor: const Color(0xFF7F7F7F),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  tabs: [
                    Tab(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Text('Current'),
                          Positioned(
                            top: -2,
                            right: -8,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE25B38), // red dot
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(text: 'Previous'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentOrdersTab(context),
                  _buildPreviousOrdersTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOrdersTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/consts/notfound.png', width: 180, height: 180),
            const Gap(30),
            Text(
              'No active orders right now',
              style: AppTextStyle.poppins20Bold,
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              'You can discover more delicious dishes and order them easily!',
              style: AppTextStyle.poppins14.copyWith(
                color: AppColors.darkGrey400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousOrdersTab(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading || state is OrderInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary500));
        } else if (state is OrderError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is OrderLoaded) {
          final pastOrders = state.orders;

          if (pastOrders.isEmpty) {
            return Center(
              child: Text(
                'No previous orders found',
                style: AppTextStyle.poppins16Bold.copyWith(color: AppColors.darkGrey400),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: pastOrders.length,
            itemBuilder: (context, index) {
              final order = pastOrders[index];
              final orderDate = DateFormat('dd MMMM').format(order.createdAt);
              final totalPrice = double.tryParse(order.total) ?? 0.0;
              final summary = order.items.map((i) => '${i.name} x${i.quantity}').join(', ');
              final imageUrl = order.items.isNotEmpty ? order.items.first.imageUrl : 'assets/products/o_pizza.png';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: imageUrl.startsWith('http') 
                             ? Image.network(imageUrl, width: 90, height: 90, fit: BoxFit.cover)
                             : Image.asset(imageUrl, width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        const Gap(15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ${order.status}',
                                style: AppTextStyle.poppins18Bold.copyWith(
                                  color: const Color(0xFF2E3E5C),
                                ),
                              ),
                              const Gap(6),
                              Row(
                                children: [
                                  Text(
                                    'Delivered on',
                                    style: AppTextStyle.poppins14.copyWith(
                                      color: const Color(0xFF7F8E9C),
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    orderDate,
                                    style: AppTextStyle.poppins14Bold.copyWith(
                                      color: const Color(0xFF2E3E5C),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order summary',
                                    style: AppTextStyle.poppins14.copyWith(
                                      color: const Color(0xFF7F8E9C),
                                    ),
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      summary,
                                      style: AppTextStyle.poppins14Bold.copyWith(
                                        color: const Color(0xFF2E3E5C),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Row(
                                children: [
                                  Text(
                                    'Total price paid',
                                    style: AppTextStyle.poppins14.copyWith(
                                      color: const Color(0xFF7F8E9C),
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '\$${totalPrice.toStringAsFixed(2)}',
                                    style: AppTextStyle.poppins14Bold.copyWith(
                                      color: const Color(0xFF2E3E5C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              const Gap(15),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reordered ${summary} successfully!',
                            ),
                            backgroundColor: AppColors.lightPrimary600,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Reorder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2E3E5C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF2E3E5C),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

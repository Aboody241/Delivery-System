import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/controller/order/cubit/order_cubit.dart';
import 'package:bobo/controller/order/cubit/order_state.dart';
import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:bobo/controller/order/models/order_model.dart';
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

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userId = await AuthService().getCurrentUserUid() ?? 'guest';
    if (mounted) {
      context.read<OrderCubit>().fetchUserOrders(userId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
      case 'delivering':
      case 'accepted':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _reorderItems(BuildContext context, OrderModel order) {
    for (final item in order.items) {
      context.read<CartCubit>().addItem(
        CartItem(
          id: item.productId,
          title: item.name,
          price: double.tryParse(item.price) ?? 0.0,
          imageUrl: item.imageUrl,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items added to cart successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track Order #${order.orderId}',
                style: AppTextStyle.poppins20Bold,
              ),
              const Gap(20),
              Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.lightPrimary500, size: 16),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${order.status.toUpperCase()}',
                          style: AppTextStyle.poppins16Bold,
                        ),
                        const Gap(4),
                        Text(
                          'Your order is being processed and updated by the restaurant.',
                          style: AppTextStyle.poppins14.copyWith(color: AppColors.darkGrey400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(30),
              CustomButton2(
                onPressed: () => Navigator.pop(context),
                title: 'Close',
                hei: 50,
              ),
            ],
          ),
        );
      },
    );
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
                    color: const Color(0xFFF3F5F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BlocBuilder<OrderCubit, OrderState>(
                    builder: (context, state) {
                      bool hasActiveOrders = false;
                      if (state is OrderLoaded) {
                        hasActiveOrders = state.orders.any((o) =>
                          o.status.toLowerCase() != 'completed' &&
                          o.status.toLowerCase() != 'cancelled' &&
                          o.status.toLowerCase() != 'delivered'
                        );
                      }

                      return TabBar(
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
                                if (hasActiveOrders)
                                  Positioned(
                                    top: -2,
                                    right: -8,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE25B38),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Tab(text: 'Previous'),
                        ],
                      );
                    },
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

            Text("*Please Don't foget to refresh the page \nto update the order state",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey
            ),
            ),
            Gap(8)
          ],
        ),
    ));
  }

  Widget _buildCurrentOrdersTab(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading || state is OrderInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary500));
        } else if (state is OrderError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is OrderLoaded) {
          final currentOrders = state.orders.where((o) =>
            o.status.toLowerCase() != 'completed' &&
            o.status.toLowerCase() != 'cancelled' &&
            o.status.toLowerCase() != 'delivered'
          ).toList();

          if (currentOrders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
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
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: _buildOrdersList(currentOrders, isActive: true),
          );
        }
        return const SizedBox.shrink();
      },
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
          final pastOrders = state.orders.where((o) =>
            o.status.toLowerCase() == 'completed' ||
            o.status.toLowerCase() == 'cancelled' ||
            o.status.toLowerCase() == 'delivered'
          ).toList();

          if (pastOrders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/consts/notfound.png', width: 180, height: 180),
                            const Gap(30),
                            Text(
                              'No previous orders found',
                              style: AppTextStyle.poppins20Bold,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: _buildOrdersList(pastOrders, isActive: false),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, {required bool isActive}) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final orderDate = DateFormat('dd MMMM yyyy HH:mm').format(order.createdAt);
        final totalPrice = double.tryParse(order.total) ?? 0.0;
        final summary = order.items.map((i) => '${i.name} x${i.quantity}').join(', ');
        final imageUrl = order.items.isNotEmpty ? order.items.first.imageUrl : 'assets/products/o_pizza.png';

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECECEC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.startsWith('http')
                        ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                        : Image.asset(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const Gap(15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.orderId}',
                              style: AppTextStyle.poppins16Bold.copyWith(
                                color: const Color(0xFF2E3E5C),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: AppTextStyle.poppins12.copyWith(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                        Text(
                          orderDate,
                          style: AppTextStyle.poppins12.copyWith(
                            color: const Color(0xFF7F8E9C),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          summary,
                          style: AppTextStyle.poppins14Bold.copyWith(
                            color: const Color(0xFF2E3E5C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFECECEC)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyle.poppins12.copyWith(
                          color: const Color(0xFF7F8E9C),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyle.poppins16Bold.copyWith(
                          color: const Color(0xFF2E3E5C),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isActive)
                        ElevatedButton(
                          onPressed: () {
                            _showOrderDetailsDialog(context, order);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Track Order'),
                        )
                      else
                        OutlinedButton(
                          onPressed: () {
                            _reorderItems(context, order);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.lightPrimary500),
                            foregroundColor: AppColors.lightPrimary500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Reorder'),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

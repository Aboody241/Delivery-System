import 'dart:ui';

import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:bobo/features/home/models/products_model.dart';
import 'package:bobo/controller/product/cubit/product_cubit.dart';
import 'package:bobo/controller/product/cubit/product_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeProductsList extends StatefulWidget {
  const HomeProductsList({super.key});

  @override
  State<HomeProductsList> createState() => HomeProductsListState();
}

class HomeProductsListState extends State<HomeProductsList> {
  @override
  void initState() {
    super.initState();
    // Load products on init if not loaded
    context.read<ProductCubit>().loadProducts();
  }

  Future<void> refreshProducts() async {
    await context.read<ProductCubit>().refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final isLoading = state is ProductLoading || state is ProductInitial;

        if (state is ProductError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${state.message}')),
          );
        }

        final List<Product> foods;
        if (isLoading) {
          foods = List.generate(
            6,
            (index) => Product(
              name: 'Loading Product Name',
              price: 0.0,
              image: 'https://via.placeholder.com/150',
              rate: 0.0,
              disc: 'no Description',
              id: '0',
            ),
          );
        } else if (state is ProductLoaded && state.products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No products found')),
          );
        } else if (state is ProductLoaded) {
          foods = state.products;
        } else {
          foods = [];
        }

        return Skeletonizer.sliver(
          enabled: isLoading,
          child: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final food = foods[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(AppRoutes.productDetailScreen, arguments: food);
                },
                child: RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: food.image,
                                width: double.infinity,
                                height: 140,
                                fit: BoxFit.cover,
                                memCacheWidth: 400, // 🔥 مهم
                                memCacheHeight: 400,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[300]),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8, // ⬆️ زيادة شوية
                                    vertical: 3, // ⬆️ زيادة شوية
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFC107),
                                        size: 22,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        food.rate.toString(),
                                        style: AppTextStyle.poppins14.copyWith(
                                          color: AppColors.darkGrey300,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: AppTextStyle.poppins16.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(7),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${food.price}",
                                    style: AppTextStyle.poppins20Bold,
                                  ),
                                  BlocBuilder<CartCubit, List<CartItem>>(
                                    builder: (context, cartItems) {
                                      final isAdded = cartItems.any(
                                        (item) => item.id == food.name,
                                      );
                                      return GestureDetector(
                                        onTap: () {
                                          if (isAdded) {
                                            context
                                                .read<CartCubit>()
                                                .removeItem(food.name);
                                            showSimpleNotification(
                                              Text(
                                                '${food.name} removed from Cart',
                                                style: AppTextStyle.poppins14
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                              background: Colors.redAccent,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                          } else {
                                            context.read<CartCubit>().addItem(
                                              CartItem(
                                                id: food.name,
                                                title: food.name,
                                                price: food.price,
                                                imageUrl: food.image,
                                              ),
                                            );
                                            showSimpleNotification(
                                              Text(
                                                '${food.name} added to Cart',
                                                style: AppTextStyle.poppins14
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                              background:
                                                  AppColors.darkGradientDark,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.15),
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            child: isAdded
                                                ? const Icon(
                                                    Icons.check,
                                                    key: ValueKey('check'),
                                                    size: 28,
                                                    color: AppColors
                                                        .darkGradientDark,
                                                  )
                                                : const Icon(
                                                    Icons.add,
                                                    key: ValueKey('add'),
                                                    size: 28,
                                                    color: AppColors
                                                        .darkGradientDark,
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
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
              );
            }, childCount: foods.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.71,
            ),
          ),
        );
      },
    );
  }
}

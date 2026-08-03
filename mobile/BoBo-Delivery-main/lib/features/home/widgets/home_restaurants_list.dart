import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/features/home/data/models/restaurant_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeRestaurantsList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final bool isLoading;

  const HomeRestaurantsList({
    super.key,
    required this.restaurants,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final List<Restaurant> items;
    if (isLoading) {
      items = List.generate(
        4,
        (index) => Restaurant(
          id: 0,
          name: 'Loading Restaurant Name',
          description: 'This is a description placeholder.',
          address: '123 Fake Street, City',
          phone: '',
          imageUrl: 'https://via.placeholder.com/150',
          isActive: true,
        ),
      );
    } else if (restaurants.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Text('🏪', style: TextStyle(fontSize: 40)),
                Gap(10),
                Text(
                  'No active restaurants found.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      items = restaurants;
    }

    return Skeletonizer.sliver(
      enabled: isLoading,
      child: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final rest = items[index];
          return GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    Navigator.of(context, rootNavigator: true).pushNamed(
                      AppRoutes.restaurantProductsScreen,
                      arguments: rest,
                    );
                  },
            child: RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: rest.imageUrl,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            memCacheWidth: 400,
                            memCacheHeight: 300,
                            placeholder: (context, url) => Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) => const Icon(Icons.store),
                          ),
                        ),
                        if (rest.isActive && !isLoading)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Open',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rest.name,
                            style: AppTextStyle.poppins16.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Text(
                            rest.description,
                            style: AppTextStyle.poppins14.copyWith(
                              color: AppColors.darkGrey300,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(6),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 14, color: AppColors.darkGrey300),
                              const Gap(3),
                              Expanded(
                                child: Text(
                                  rest.address,
                                  style: AppTextStyle.poppins12.copyWith(
                                    color: AppColors.darkGrey300,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          );
        }, childCount: items.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.76,
        ),
      ),
    );
  }
}

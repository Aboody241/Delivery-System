import 'package:bobo/controller/favorite/cubit/favorite_cubit.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/features/home/models/products_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:bobo/core/consts/routes/routes.dart';

import 'package:bobo/services/auth_service.dart';
import 'package:bobo/core/consts/widgets/guest_access_placeholder.dart';

class FavorateScreen extends StatefulWidget {
  const FavorateScreen({super.key});

  @override
  State<FavorateScreen> createState() => _FavorateScreenState();
}

class _FavorateScreenState extends State<FavorateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CenterWidgetAppbar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/like_icon.svg',
                width: 40,
                height: 40,
              ),
              Text('Favorites', style: AppTextStyle.poppins22Bold),
            ],
          ),
        ),
      ),
      body: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLoggedIn = authSnapshot.data ?? false;
          if (!isLoggedIn) {
            return const GuestAccessPlaceholder(
              title: 'Login Required',
              description: 'Please log in or register to view and save your favorite meals.',
              icon: Icons.favorite_border,
            );
          }

          return BlocBuilder<FavoriteCubit, List<Product>>(
            builder: (context, state) {
              if (state.isEmpty) {
                return Center(
                  child: Center(
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
                          'There is no Products\n in the Favorites!',
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
                ),
                );
              }

              return ListView.builder(
                itemCount: state.length,
                itemBuilder: (context, index) {
                  final product = state[index];
                  return Container(
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pushNamed(
                          AppRoutes.productDetailScreen,
                          arguments: product,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                            child: CachedNetworkImage(
                              width: 140,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: product.image,
                              memCacheWidth: 500,
                              memCacheHeight: 500,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Gap(15),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: AppColors.darkGrey300,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  '\$ ${product.price.toStringAsFixed(2)}',
                                  style: AppTextStyle.poppins18.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.grey,
                              size: 28,
                            ),
                            onPressed: () {
                              context.read<FavoriteCubit>().toggleFavorite(product);
                            },
                          ),
                          const Gap(5),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

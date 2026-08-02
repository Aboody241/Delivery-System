import 'package:bobo/controller/favorite/cubit/favorite_cubit.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/features/home/models/products_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:overlay_support/overlay_support.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double currentIndex = 0;
  int productNum = 1;
  bool isExpanded = false;

  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! Product) {
      return const Scaffold(
        body: Center(child: Text('Error: No product data found!')),
      );
    }

    final product = args;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Details', style: AppTextStyle.poppins24Bold),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share, color: AppColors.darkGrey100),
          ),

          // ✅ BlocBuilder فقط بدون isFavorate محلية
          BlocBuilder<FavoriteCubit, List<Product>>(
            builder: (context, state) {
              final cubit = context.read<FavoriteCubit>();
              final isFav = cubit.isfavorite(product.id);

              return GestureDetector(
                onTap: () => cubit.toggleFavorite(product),
                child: TweenAnimationBuilder<double>(
                  curve: Curves.elasticOut,
                  tween: Tween<double>(begin: 28, end: isFav ? 40 : 28),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, double size, child) {
                    return Icon(
                      isFav ? Icons.favorite : Icons.favorite_border_rounded,
                      size: size,
                      color: isFav
                          ? Colors.red
                          : Theme.of(context).colorScheme.onSurface,
                    );
                  },
                ),
              );
            },
          ),

          const Gap(10),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          /// 🔥 الصور
          SliverToBoxAdapter(
            child: SizedBox(
              height: 380,
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() => currentIndex = index.toDouble());
                      },
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              memCacheWidth: 800,
                              memCacheHeight: 800,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ DotsIndicator بس لو عندك أكتر من صورة
                  // لو هتضيف صور تانية في المستقبل، ضيف List<String> images في الـ Product model
                  // وغيّر dotsCount: product.images.length
                  // في الوقت الحالي وهي صورة واحدة، ممكن تحذف الـ DotsIndicator ده
                  DotsIndicator(
                    dotsCount: 1,
                    position: currentIndex,
                    decorator: const DotsDecorator(
                      size: Size(16, 16),
                      activeSize: Size(18, 18),
                      color: Color.fromARGB(255, 225, 225, 225),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔥 التفاصيل
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),

                  /// ⭐ Rating
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rate_rounded,
                              color: Color(0xffF5AE42),
                              size: 30,
                            ),
                            Text(
                              product.rate.toString(),
                              style: AppTextStyle.poppins16,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/products/ckals.svg',
                              width: 20,
                              height: 20,
                            ),
                            const Gap(4),
                            Text(
                              '${product.calories} kcal',
                              style: AppTextStyle.poppins16,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.watch_later_sharp,
                              size: 20,
                              color: AppColors.darkBlue,
                            ),
                            const Gap(4),
                            Text(
                              '${product.deliveryTime} mins',
                              style: AppTextStyle.poppins16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Gap(20),

                  /// 🔥 الاسم + الكمية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyle.poppins20Bold,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            /// ➖
                            GestureDetector(
                              onTap: () {
                                if (productNum > 1) {
                                  setState(() => productNum--);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.lightGrey200,
                                ),
                                child: const Icon(Icons.remove, size: 26),
                              ),
                            ),

                            const Gap(10),

                            AnimatedDefaultTextStyle(
                              style: AppTextStyle.poppins20Bold.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              duration: const Duration(milliseconds: 300),
                              child: Text(productNum.toString()),
                            ),

                            const Gap(10),

                            /// ➕
                            GestureDetector(
                              onTap: () => setState(() => productNum++),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.lightGrey200,
                                ),
                                child: const Icon(Icons.add, size: 26),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(10),

                  /// 📝 الوصف - ✅ تم دمج الـ GestureDetector في widget واحدة
                  GestureDetector(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.disc ?? 'No description', // ✅ typo fix
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: AppTextStyle.poppins16.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        // ✅ TextButton بدل GestureDetector تاني
                        Text(
                          isExpanded ? 'See less' : 'Read more',
                          style: AppTextStyle.poppins14Bold.copyWith(
                            color: AppColors.darkGrey400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(50),
                ],
              ),
            ),
          ),
        ],
      ),

      /// 🔥 السعر + زرار
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        child: Row(
          children: [
            Text(
              '\$${(product.price * productNum).toStringAsFixed(2)}',
              style: AppTextStyle.poppins24Bold,
            ),
            const Gap(20),
            Expanded(
              child: CustomButton2(
                onPressed: () {
                  context.read<CartCubit>().addItemWithQuantity(
                    CartItem(
                      id: product.name,
                      title: product.name,
                      price: product.price,
                      imageUrl: product.image,
                    ),
                    productNum,
                  );
                  showSimpleNotification(
                    Text(
                      '$productNum x ${product.name} added to Cart',
                      style: AppTextStyle.poppins14.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    background: AppColors.darkGradientDark,
                    duration: const Duration(seconds: 2),
                  );
                },
                title: 'Add to cart',
                hei: 55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

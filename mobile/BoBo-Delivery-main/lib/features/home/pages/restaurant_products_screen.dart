import 'package:bobo/controller/cart/cubit/cart_cubit.dart';
import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_buttons.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/features/cart/models/cart_class.dart';
import 'package:bobo/features/home/models/products_model.dart';
import 'package:bobo/features/home/models/restaurant_model.dart';
import 'package:bobo/core/network/dio_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RestaurantCategory {
  final int id;
  final String name;
  RestaurantCategory({required this.id, required this.name});
}

class RestaurantProductsScreen extends StatefulWidget {
  const RestaurantProductsScreen({super.key});

  @override
  State<RestaurantProductsScreen> createState() => _RestaurantProductsScreenState();
}

class _RestaurantProductsScreenState extends State<RestaurantProductsScreen> {
  late Restaurant _restaurant;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<RestaurantCategory> _categories = [RestaurantCategory(id: 0, name: 'All')];
  
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;
      _loadData();
      _isInit = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = DioClient().dio;

      // 1. Fetch categories
      final catResponse = await dio.get('/restaurants/${_restaurant.id}/categories');
      if (catResponse.data != null && catResponse.data['status'] == 'success') {
        final List catList = catResponse.data['data'] ?? [];
        _categories = [
          RestaurantCategory(id: 0, name: 'All'),
          ...catList.map((json) => RestaurantCategory(
                id: json['id'] ?? 0,
                name: json['name'] ?? '',
              )),
        ];
      }

      // 2. Fetch products
      final prodResponse = await dio.get('/restaurants/${_restaurant.id}/products');
      if (prodResponse.data != null && prodResponse.data['status'] == 'success') {
        final List prodList = prodResponse.data['data'] ?? [];
        _allProducts = prodList.map((json) => Product.fromJson(json)).toList();
        _filteredProducts = _allProducts;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    final selectedCat = _categories[_selectedCategoryIndex];

    setState(() {
      _filteredProducts = _allProducts.where((prod) {
        final matchesSearch = prod.name.toLowerCase().contains(query) ||
            (prod.disc?.toLowerCase().contains(query) ?? false);
        
        final matchesCategory = selectedCat.id == 0 || prod.categoryId == selectedCat.id;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CenterChildAndBackAppbar(
          title: Text(_isInit ? 'Restaurant' : _restaurant.name, style: AppTextStyle.poppins22Bold),
          leading: const CustomBackButton(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 30)),
                      const Gap(10),
                      Text('Failed to load menu: $_errorMessage', textAlign: TextAlign.center),
                      const Gap(15),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Try Again'),
                      )
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Restaurant Header Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: _isInit
                                  ? Container(height: 140, color: Colors.grey[300])
                                  : CachedNetworkImage(
                                      imageUrl: _restaurant.imageUrl,
                                      width: double.infinity,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => const Icon(Icons.store, size: 50),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isInit ? 'Loading...' : _restaurant.name,
                                    style: AppTextStyle.poppins18Bold,
                                  ),
                                  const Gap(4),
                                  Text(
                                    _isInit ? '' : _restaurant.description,
                                    style: AppTextStyle.poppins14.copyWith(color: AppColors.darkGrey300),
                                  ),
                                  const Gap(8),
                                  Row(
                                    children: [
                                      const Icon(Icons.place_outlined, size: 16, color: AppColors.darkGrey300),
                                      const Gap(4),
                                      Expanded(
                                        child: Text(
                                          _isInit ? '' : _restaurant.address,
                                          style: AppTextStyle.poppins12.copyWith(color: AppColors.darkGrey300),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    // Search Bar
                    SliverPersistentHeader(
                      floating: true,
                      delegate: SearchBarDelegate(_searchController),
                    ),

                    // Category scroll list
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              bool isSelected = index == _selectedCategoryIndex;
                              final cat = _categories[index];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                  _filterProducts();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.lightGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderColor),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.darkGreen
                                            : AppColors.darkGrey300,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Products list
                    _isLoading
                        ? Skeletonizer.sliver(
                            enabled: true,
                            child: SliverGrid(
                              delegate: SliverChildBuilderDelegate((context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Column(
                                    children: [
                                      Gap(100),
                                      Text('Loading...'),
                                    ],
                                  ),
                                );
                              }, childCount: 6),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.92,
                              ),
                            ),
                          )
                        : _filteredProducts.isEmpty
                            ? const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Text('No products found in this menu.', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              )
                            : SliverGrid(
                                delegate: SliverChildBuilderDelegate((context, index) {
                                  final food = _filteredProducts[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true).pushNamed(
                                        AppRoutes.productDetailScreen,
                                        arguments: food,
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
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                                  child: CachedNetworkImage(
                                                    imageUrl: food.image,
                                                    width: double.infinity,
                                                    height: 110,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                                                    errorWidget: (context, url, error) => const Icon(Icons.fastfood),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 4,
                                                  left: 4,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: Theme.of(context).cardColor,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                                                        const Gap(2),
                                                        Text(food.rate.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                      ],
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
                                                    style: AppTextStyle.poppins14.copyWith(fontWeight: FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const Gap(4),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("\$${food.price}", style: AppTextStyle.poppins16Bold),
                                                      BlocBuilder<CartCubit, List<CartItem>>(
                                                        builder: (context, cartItems) {
                                                          final isAdded = cartItems.any((item) => item.id == food.id);
                                                          return GestureDetector(
                                                            onTap: () {
                                                              if (isAdded) {
                                                                context.read<CartCubit>().removeItem(food.id);
                                                                showSimpleNotification(
                                                                  Text('${food.name} removed from Cart', style: const TextStyle(color: Colors.white)),
                                                                  background: Colors.redAccent,
                                                                );
                                                              } else {
                                                                context.read<CartCubit>().addItem(
                                                                      CartItem(
                                                                        id: food.id,
                                                                        title: food.name,
                                                                        price: food.price,
                                                                        imageUrl: food.image,
                                                                      ),
                                                                    );
                                                                showSimpleNotification(
                                                                  Text('${food.name} added to Cart', style: const TextStyle(color: Colors.white)),
                                                                  background: AppColors.darkGradientDark,
                                                                );
                                                              }
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets.all(4),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                                              ),
                                                              child: Icon(
                                                                isAdded ? Icons.check : Icons.add,
                                                                size: 20,
                                                                color: AppColors.darkGradientDark,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }, childCount: _filteredProducts.length),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.92,
                                ),
                              ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;

  SearchBarDelegate(this.controller);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: CustomSearchBar(controller: controller),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) =>
      oldDelegate.controller != controller;
}

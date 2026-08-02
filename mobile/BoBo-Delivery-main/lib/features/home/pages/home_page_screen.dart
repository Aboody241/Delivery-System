import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/features/home/widgets/category_cards.dart';
import 'package:bobo/features/home/widgets/home_appbar.dart';
import 'package:bobo/features/home/widgets/home_products_list.dart';
import 'package:bobo/features/home/widgets/home_slider_banner.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  TextEditingController searchController = TextEditingController();
  final GlobalKey<HomeProductsListState> _productsListKey =
      GlobalKey<HomeProductsListState>();

  // Example categories
  final List<String> categoryNames = ['Offers', 'Burger', 'Pizza', 'Donut'];

  int selectedCategoryIndex = 0; // افتراضياً أول عنصر مختار

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: HomeAppbar(),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: RefreshIndicator(
            onRefresh: () async {
              await _productsListKey.currentState?.refreshProducts();
            },
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  floating: true,
                  delegate: SearchBarDelegate(searchController),
                ),

                SliverPadding(
                  padding: const EdgeInsets.only(top: 10),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryNames.length,
                        itemBuilder: (context, index) {
                          bool isSelected = index == selectedCategoryIndex;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: CategoriesCard(
                              index: index,
                              categoryName: categoryNames[index],
                              isSelected: isSelected,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: HomeSliderBanner()),

                HomeProductsList(key: _productsListKey),
              ],
            ),
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

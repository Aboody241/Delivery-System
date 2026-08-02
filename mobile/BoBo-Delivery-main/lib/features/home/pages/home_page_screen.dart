import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/features/home/widgets/category_cards.dart';
import 'package:bobo/features/home/widgets/home_appbar.dart';
import 'package:bobo/features/home/widgets/home_restaurants_list.dart';
import 'package:bobo/features/home/widgets/home_slider_banner.dart';
import 'package:bobo/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  TextEditingController searchController = TextEditingController();
  final GlobalKey<HomeRestaurantsListState> _restaurantsListKey =
      GlobalKey<HomeRestaurantsListState>();

  List<String> categoryNames = ['All'];
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/categories');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        final List dataList = responseData['data'] ?? [];
        final List<String> names = dataList
            .map((json) => json['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        if (names.isNotEmpty) {
          if (mounted) {
            setState(() {
              categoryNames = names;
            });
          }
        }
      }
    } catch (_) {}
  }

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
              await _restaurantsListKey.currentState?.loadRestaurants();
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

                HomeRestaurantsList(key: _restaurantsListKey),
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

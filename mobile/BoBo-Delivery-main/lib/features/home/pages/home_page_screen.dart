import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/features/home/widgets/category_cards.dart';
import 'package:bobo/features/home/widgets/home_appbar.dart';
import 'package:bobo/features/home/widgets/home_restaurants_list.dart';
import 'package:bobo/features/home/widgets/home_slider_banner.dart';
import 'package:bobo/features/home/presentation/cubit/home_cubit.dart';
import 'package:bobo/features/home/presentation/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  TextEditingController searchController = TextEditingController();
  int selectedCategoryIndex = 0;

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
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeInitial) {
                context.read<HomeCubit>().loadHomeData();
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 30)),
                      const SizedBox(height: 10),
                      Text(
                        'Failed to load data: ${state.message}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeCubit>().loadHomeData();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final homeLoaded = state as HomeLoaded;
              final categoryNames = homeLoaded.categories;

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<HomeCubit>().refreshHomeData();
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

                    HomeRestaurantsList(
                      restaurants: homeLoaded.restaurants,
                      isLoading: false,
                    ),
                  ],
                ),
              );
            },
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

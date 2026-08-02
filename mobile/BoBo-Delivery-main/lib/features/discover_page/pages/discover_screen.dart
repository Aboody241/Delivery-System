import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:bobo/features/discover_page/service/categories_service.dart';
import 'package:bobo/features/discover_page/widget/discover_category_class.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(50),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: CustomSearchBar(controller: searchController),
          ),

          StreamBuilder<List<DiscoverCategoryClass>>(
            stream: getDiscoverCategories(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const NoDataWidget();
              }

              final categories = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: double.infinity, // ياخد عرض الشاشة كله
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: categories[index].child.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: categories[index].child,
                                fit: BoxFit.cover, // أفضل من fill

                                placeholder: (context, url) => Center(
                                  child: Container(color: Colors.grey[300]),
                                ),
                                memCacheHeight: 1300,
                                memCacheWidth: 1300,

                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            //  Image.network(
                            //     categories[index].child,
                            //     loadingBuilder: (context, child, loadingProgress) {
                            //       if (loadingProgress == null) return child;
                            //       return Center(
                            //         child: CircularProgressIndicator(
                            //           value: loadingProgress.expectedTotalBytes != null
                            //               ? loadingProgress.cumulativeBytesLoaded /
                            //                   loadingProgress.expectedTotalBytes!
                            //               : null,
                            //         ),
                            //       );
                            //     },
                            //     errorBuilder: (context, error, stackTrace) {
                            //       return const Center(
                            //         child: CircularProgressIndicator(),
                            //       );
                            //     },
                            //   )
                            : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text("There is No data !", style: AppTextStyle.poppins16Bold),
        ),
      ),
    );
  }
}

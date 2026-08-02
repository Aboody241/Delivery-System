import 'package:bobo/features/discover_page/widget/discover_category_class.dart';

Stream<List<DiscoverCategoryClass>> getDiscoverCategories() {
  return Stream.value([
    DiscoverCategoryClass(child: 'Chicken Burgers'),
    DiscoverCategoryClass(child: 'Bucket Meals'),
    DiscoverCategoryClass(child: 'Woodfired Pizzas'),
  ]);
}

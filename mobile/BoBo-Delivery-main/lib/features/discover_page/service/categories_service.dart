import 'package:bobo/features/discover_page/widget/discover_category_class.dart';
import 'package:bobo/core/network/dio_client.dart';

Stream<List<DiscoverCategoryClass>> getDiscoverCategories() async* {
  try {
    final dio = DioClient().dio;
    
    // 1. Fetch active restaurants
    final restaurantsResponse = await dio.get('/restaurants');
    int restaurantId = 1;

    if (restaurantsResponse.data != null && 
        restaurantsResponse.data['status'] == 'success') {
      final List restaurants = restaurantsResponse.data['data'] ?? [];
      if (restaurants.isNotEmpty) {
        restaurantId = restaurants.first['id'] ?? 1;
      }
    }

    // 2. Fetch categories for that restaurant
    final response = await dio.get('/restaurants/$restaurantId/categories');
    final responseData = response.data;

    if (responseData['status'] == 'success') {
      final List dataList = responseData['data'] ?? [];
      yield dataList.map((json) => DiscoverCategoryClass.fromJson(json)).toList();
    } else {
      yield [];
    }
  } catch (_) {
    yield [];
  }
}

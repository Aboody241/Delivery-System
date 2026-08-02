import 'package:bobo/features/discover_page/widget/discover_category_class.dart';
import 'package:bobo/core/network/dio_client.dart';

Stream<List<DiscoverCategoryClass>> getDiscoverCategories() async* {
  try {
    final dio = DioClient().dio;
    final response = await dio.get('/categories');
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

class DiscoverCategoryClass {
  String child;

  DiscoverCategoryClass({required this.child});

  factory DiscoverCategoryClass.fromJson(Map<String, dynamic> json) {
    return DiscoverCategoryClass(
      child: json['chlid'] ?? '',
    );
  }
}

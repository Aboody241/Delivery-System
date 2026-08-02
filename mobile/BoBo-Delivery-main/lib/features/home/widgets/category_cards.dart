import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';

class CategoriesCard extends StatelessWidget {
  const CategoriesCard({
    super.key,
    required this.index,
    required this.categoryName,
    this.isSelected = false,
  });

  final int index;
  final String categoryName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // fixed width for horizontal scroll
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.back),
      ),
      child: Center(
        child: Text(
          categoryName,
          style: AppTextStyle.poppins16.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/core/consts/widgets/custom_appbar.dart';
import 'package:bobo/core/consts/widgets/custom_forms.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddCoupone extends StatefulWidget {
  const AddCoupone({super.key});

  @override
  State<AddCoupone> createState() => _AddCouponeState();
}

class _AddCouponeState extends State<AddCoupone> {
  String? _selectedCouponCode = 'WELCOME50';
  bool _isInitialized = false;

  final List<Map<String, String>> coupons = [
    {
      'code': 'PIZZA10',
      'description': 'Get 10% off on any pizza order.',
    },
    {
      'code': 'WELCOME50',
      'description': '50% off your first order!',
    },
    {
      'code': 'WEEKEND5',
      'description': 'Save \$5 on orders over \$25 this weekend.',
    },
    {
      'code': 'EXTRA20',
      'description': '20% off on orders above \$30.',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        setState(() {
          _selectedCouponCode = args;
        });
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CancelSaveAppBar(
        title: 'Add Coupon',
        onSave: () {
          Navigator.pop(context, _selectedCouponCode);
        },
      ),

      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: Gap(15)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: BasicTextField(hintText: 'type coupon name'),
                  ),
                  const Gap(10),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 56, // Align height with BasicTextField
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBECE9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Add',
                          style: AppTextStyle.poppins16Bold.copyWith(
                            color: const Color(0xFF9EA09C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Gap(20)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                color: Color(0xFFECECEC),
                thickness: 1,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Gap(20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Select from these',
                style: AppTextStyle.poppins14Bold.copyWith(
                  color: AppColors.lightTypography300,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Gap(15)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final coupon = coupons[index];
                final isSelected = _selectedCouponCode == coupon['code'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCouponCode = coupon['code'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAF8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon['code']!,
                                  style: AppTextStyle.poppins12.copyWith(
                                    color: AppColors.lightTypography200,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  coupon['description']!,
                                  style: AppTextStyle.poppins16.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(15),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.lightPrimary500 : const Color(0xFFEBECE9),
                                width: 2,
                              ),
                              color: Colors.transparent,
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.lightPrimary500,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: coupons.length,
            ),
          ),
          const SliverToBoxAdapter(child: Gap(20)),
        ],
      ),
    );
  }
}

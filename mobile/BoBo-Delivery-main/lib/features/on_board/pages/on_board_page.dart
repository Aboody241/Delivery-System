import 'package:bobo/core/consts/routes/routes.dart';
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:bobo/features/on_board/widgets/on_board_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, AppRoutes.onBoardingAuth);
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Get Started
      _onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          "assets/consts/black_name.png",
          width: 65.w,
          height: 65.h,
        ),
      ),
      body: Column(
        children: [
          // PageView �"�����. �S���'�% ���^�� Expanded
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [Onboard1(), Onboard2(), Onboard3()],
            ),
          ),

          DotsIndicator(
            dotsCount: 3,
            position: _currentPage.toDouble(), // double
            animate: true,
            animationDuration: const Duration(milliseconds: 400),
            decorator: DotsDecorator(
              size: Size(12.w, 12.w), // ���. ���"���'���� ���"�������S��
              activeSize: Size(
                14.w,
                14.w,
              ), // ���. ���"���'���� ���"�.�?���'�"��

              activeColor: AppColors.lightPrimary600,
              color: AppColors.lightGrey200,
            ),
          ),

          Gap(40.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // لو احنا مش في آخر صفحة → اعرض Skip
                if (_currentPage < 2)
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _onSkip,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 20.w,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppColors.lightGrey200,
                        ),
                        child: Center(
                          child: Text(
                            "Skip",
                            style: AppTextStyle.poppins16Bold.copyWith(
                              color: AppColors.lightPrimary600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // مسافة بين الأزرار لو Skip ظاهر
                if (_currentPage < 2) Gap(10.w),

                // زر Next / Get Started
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 20.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.lightPrimary600,
                      ),
                      child: Center(
                        child: Text(
                          _currentPage < 2 ? "Next" : "Get Started",
                          style: AppTextStyle.poppins16Bold.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Gap(40.h),
        ],
      ),
    );
  }
}

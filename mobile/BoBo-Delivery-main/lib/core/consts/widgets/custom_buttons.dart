import 'package:bobo/core/consts/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.gradient,
    this.textColor = Colors.white,
  });

  final VoidCallback? onPressed; // لازم تبقى nullable
  final String text;
  final LinearGradient gradient;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 60,    child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isDisabled ? null : gradient,
          color: isDisabled ? Colors.grey.shade400 : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isDisabled ? Colors.white70 : textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton2 extends StatelessWidget {
  const CustomButton2({
    super.key,
    required this.title,
    required this.onPressed, required this.hei,
  });

  final String title;
  final VoidCallback onPressed;

  final double hei;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: hei,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0, // مفيش ظل
          backgroundColor: AppColors.lightPrimary600, // الأخضر
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Rounded قوي
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}




class EnabledButton extends StatelessWidget {
  const EnabledButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.hei,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double hei;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: hei,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.darkGrey400;
              }
              return AppColors.lightPrimary600;
            },
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        child: child
      ),
    );
  }
}




class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_sharp),
        );
  }
}
import 'package:bobo/core/consts/theme/colors.dart';
import 'package:bobo/core/consts/theme/fonts.dart';
import 'package:flutter/material.dart';

class BasicTextField extends StatelessWidget {
  const BasicTextField({
    super.key,
    required this.hintText,
    this.suffix,
    this.isvisable,
    this.onchange,
    this.controller,
    this.keyboardtype, this.prefexIcon, this.padding,
  });
  final String hintText;

  final Widget? suffix;

  final bool? isvisable;
  final Function(String)? onchange;
  final TextEditingController? controller;
  final TextInputType? keyboardtype;

  final Widget? prefexIcon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      
      keyboardType: keyboardtype,
      controller: controller,
      onChanged: onchange,
      obscureText: isvisable ?? false,
      decoration: InputDecoration(
        contentPadding: padding,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 219, 219, 219),
            width: 1.3, // usually 4 is quite thick for a text field
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: AppColors.darkGradientDark, // color when focused
            width: 2,
          ),
        ),
        hintStyle: AppTextStyle.poppins14.copyWith(
          color: AppColors.darkGrey300,
        ),
        suffixIcon: suffix,
        prefix: prefexIcon
      ),
    );
  }
}

class Passwordfields extends StatefulWidget {
  const Passwordfields({super.key, required this.hintText, this.controller});
  final String hintText;

  final TextEditingController? controller;

  @override
  State<Passwordfields> createState() => _PasswordfieldsState();
}

class _PasswordfieldsState extends State<Passwordfields> {
  bool isvisable = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: isvisable,
      decoration: InputDecoration(
        hintText: widget.hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 219, 219, 219),
            width: 1.3, // usually 4 is quite thick for a text field
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: AppColors.darkGradientDark, // color when focused
            width: 2,
          ),
        ),
        hintStyle: AppTextStyle.poppins14.copyWith(
          color: AppColors.darkGrey300,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isvisable = !isvisable;
            });
          },
          icon: isvisable
              ? Icon(Icons.visibility_off_outlined)
              : Icon(Icons.remove_red_eye_outlined),
        ),
      ),
    );
  }
}



class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    this.hintText = 'search...',
    this.onChanged,
    this.controller,
  });

  final String hintText;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[000], // خلفية فاتحة مثل الصورة
        borderRadius: BorderRadius.circular(15), 
        border:Border.all(
          color: AppColors.borderColor,
          width: 1.5
        )// أركان دائرية خفيفة
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.darkGradientDark)
          ),
          icon: const Icon(Icons.search_rounded, color: Colors.grey),
          hintText: hintText,
          border: InputBorder.none, // نشيل الخطوط الافتراضية
        ),
      ),
    );
  }
}

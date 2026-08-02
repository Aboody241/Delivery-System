import 'package:flutter/material.dart';

class MainLogo extends StatelessWidget {
  const MainLogo({super.key, required this.height, required this.wedth});

  final double height;
  final double wedth;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/consts/black_name.png' , width: wedth , height: height,);
  }
}


import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeSliderBanner extends StatelessWidget {
  const HomeSliderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: const [SliderBannerItem1(), SliderBannerItem2()],
      options: CarouselOptions(
        height: 180.0,
        enableInfiniteScroll: false,
        autoPlay: true,
        autoPlayAnimationDuration: Duration(seconds: 2),
        autoPlayCurve: Curves.easeInOut,
        aspectRatio: 20 / 9,
        viewportFraction: 1.01,
      ),
    );
  }
}

class SliderBannerItem1 extends StatelessWidget {
  const SliderBannerItem1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.asset('assets/products/slide_card1.png'),
    );
  }
}

class SliderBannerItem2 extends StatelessWidget {
  const SliderBannerItem2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.asset('assets/products/slide_card2.png'),
    );
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:freelancer/components/my_button.dart';
import 'package:freelancer/pages/freelancer/auth_freelancer/login_or_register_freelancer.dart';


import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BeginPage extends StatefulWidget {
  const BeginPage({super.key});

  @override
  State<BeginPage> createState() => _BeginPageState();
}

class _BeginPageState extends State<BeginPage> {
  int activeIndex = 0;
  final controller = CarouselSliderController();
  final asset = [
    "lib/images/city.jpg",
    "lib/images/slider 1.jpg",
    "lib/images/slider 2.jpg",
    "lib/images/slider 3.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(
            bottom: 25,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CarouselSlider.builder(
                          carouselController: controller,
                          itemCount: asset.length,
                          itemBuilder: (context, index, realIndex) {
                            final urlImage = asset[index];
                            return buildImage(urlImage, index);
                          },
                          options: CarouselOptions(
                              height: MediaQuery.of(context).size.height / 2,
                              autoPlay: true,
                              enableInfiniteScroll: false,
                              autoPlayAnimationDuration: Duration(seconds: 2),
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) =>
                                  setState(() => activeIndex = index))),
                      SizedBox(height: 40),
                      buildIndicator()
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    children: [
                      Text(
                        "Mở App liền tay\nCó việc làm ngay!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Chúng tôi sẽ giúp bạn tìm việc làm một cách\ndễ dàng hơn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Color.fromRGBO(98, 104, 111, 1)),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                  child: MyButton(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginOrRegisterFreelancer()),
                          (route) => false,
                        );
                      },
                      text: "Bắt Đầu"),
                )
              ],
            ),
          ),
        ));
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        onDotClicked: animateToSlide,
        effect: ExpandingDotsEffect(
            dotWidth: 15,
            dotHeight: 10,
            activeDotColor: Color.fromRGBO(67, 101, 222, 1)),
        activeIndex: activeIndex,
        count: asset.length,
      );

  void animateToSlide(int index) => controller.animateToPage(index);
}

Widget buildImage(String asset, int index) =>
    Image.asset(asset, fit: BoxFit.cover);

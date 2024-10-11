// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:flutter/material.dart';

import 'package:freelancer/pages/freelancer/pages_freelancer/account_page_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/home_view_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/message_view_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/project_view_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/social_view_freelancer.dart';

class HomePageFreelancer extends StatefulWidget {
  const HomePageFreelancer({super.key});

  @override
  State<HomePageFreelancer> createState() => _HomePageFreelancerState();
}

class _HomePageFreelancerState extends State<HomePageFreelancer> {
  int _currentIndex = 0;
  List<Widget> _pages = [
    HomeViewFreelancer(),
    MessageViewFreelancer(),
    SocialViewFreelancer(),
    ProjectViewFreelancer(),
    AccountPageFreelancer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_currentIndex],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  SizedBox _bottomNavBar() {
    return SizedBox(
      height: 80,
      child: BottomNavigationBar(
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        unselectedIconTheme: IconThemeData(size: 26),
        selectedIconTheme: IconThemeData(
          color: Color.fromRGBO(67, 101, 222, 1),
          size: 26,
        ),
        selectedItemColor: Color.fromRGBO(67, 101, 222, 1),
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.home_filled,
              ),
            ),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Icons.message,
                ),
              ),
              label: 'Tin nhắn'),
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Icons.directions,
                ),
              ),
              label: 'Khám phá'),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.work,
              ),
            ),
            label: 'Dự án',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.person,
              ),
            ),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

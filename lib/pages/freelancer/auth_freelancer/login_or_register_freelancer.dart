import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/auth_freelancer/login_page_freelancer.dart';
import 'package:freelancer/pages/freelancer/auth_freelancer/register_page_freelancer.dart';

class LoginOrRegisterFreelancer extends StatefulWidget {
  const LoginOrRegisterFreelancer({super.key});

  @override
  State<LoginOrRegisterFreelancer> createState() => _LoginOrRegisterFreelancerState();
}

class _LoginOrRegisterFreelancerState extends State<LoginOrRegisterFreelancer> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return Login(onTap: togglePages);
    } else {
      return Register(onTap: togglePages);
    }
  }
}

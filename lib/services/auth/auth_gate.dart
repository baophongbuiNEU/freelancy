
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/begin_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/home_page_freelancer.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in
          // if (snapshot.hasData) {
          //   return const HomePageFreelancer();
          // } // user is NOT logged in
          // else {
          //   return const BeginPage();
          // }

          if (currentUser != null) {
            return const HomePageFreelancer();
          } else {
            return const BeginPage();
          }
        },
      ),
    );
  }
}

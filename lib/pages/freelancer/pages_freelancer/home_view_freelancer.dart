// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/categories_job_homeView_free.dart';
import 'package:freelancer/components/job_list_homeview_compo.dart';
import 'package:freelancer/components/top_user.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/all_user.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/notification_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/social_view_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/user_profile_page.dart';

class HomeViewFreelancer extends StatefulWidget {
  const HomeViewFreelancer({super.key});

  @override
  State<HomeViewFreelancer> createState() => _HomeViewFreelancerState();
}

class _HomeViewFreelancerState extends State<HomeViewFreelancer> {
  String userName = "";
  String email = "";
  String avatar = "";
  String position = "";
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userName = doc['name'] ?? "";
          email = doc['email'] ?? "";
          avatar = doc['avatar'] ?? "";
          position = doc['position'] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final doc = snapshot.data!;
            userName = doc['name'] ?? "";
            email = doc['email'] ?? "";
            avatar = doc['avatar'] ?? "";
            position = doc['position'] ?? "Chưa cập nhật";
          }
          return Scaffold(
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            body: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _header(),
                      SizedBox(
                        height: 25,
                      ),
                      _searchBar(),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tất cả dịch vụ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // Hiển thị categories về dịch vụ
                      SizedBox(
                        height: 250,
                        child: CategoriesJobHomeviewFree(),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Top các công việc hot",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SocialViewFreelancer(),
                                )),
                            child: Text(
                              "Xem tất cả",
                              style: TextStyle(
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 480,
                        child: JobListHomeviewCompo(),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Top Freelancy",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllUser(),
                                )),
                            child: Text(
                              "Xem tất cả",
                              style: TextStyle(
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 1000,
                        child: TopUser(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Container _searchBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.transparent)),
      padding: const EdgeInsets.only(
        left: 15,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 30,
            color: Color.fromRGBO(67, 101, 222, 1),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Tìm kiếm tìm việc làm ngay hôm nay!",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Row _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // user profile image
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(),
              )),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    avatar,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    position,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),

        Spacer(),
        IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(),
                  ));
            },
            icon: Icon(
              Icons.notifications,
              size: 35,
              color: Color.fromRGBO(67, 101, 222, 1),
            )),
      ],
    );
  }
}

// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/categories_job_homeView_free.dart';
import 'package:freelancer/components/job_list_homeview_compo.dart';
import 'package:freelancer/components/top_user.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/all_user.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/notification_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/recent_jobs.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/search_view.dart';
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
                padding: const EdgeInsets.only(
                  top: 15,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: _header(),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobSearchPage(),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: _searchBar(),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
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
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // Hiển thị categories về dịch vụ
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: CategoriesJobHomeviewFree(),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Các công việc gần đây",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecentJobs(),
                                    ));
                              },
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: JobListHomeviewCompo(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
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
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
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
              blurRadius: 3,
              offset: Offset(0, 2),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

        _iconNoti(),
      ],
    );
  }

  Widget _iconNoti() {
    final ValueNotifier<int> unreadNotificationCount = ValueNotifier(0);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: 'enroll_noti')
          .where('employerUID',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Icon(
            Icons.notifications_none_outlined,
            size: 35,
            color: Color.fromRGBO(67, 101, 222, 1),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(
            Icons.notifications_none_outlined,
            size: 35,
            color: Color.fromRGBO(67, 101, 222, 1),
          );
        }
        int unreadCountEnroll =
            snapshot.data!.docs.where((doc) => doc['clicked'] == false).length;
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('type', isEqualTo: 'result_noti')
              .where('candidateID',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Icon(
                Icons.notifications_none_outlined,
                size: 35,
                color: Color.fromRGBO(67, 101, 222, 1),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(
                Icons.notifications_none_outlined,
                size: 35,
                color: Color.fromRGBO(67, 101, 222, 1),
              );
            }
            int unreadCountResult = snapshot.data!.docs
                .where((doc) => doc['clicked'] == false)
                .length;
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('type', isEqualTo: 'finance_noti')
                  .where('candidateID',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                int unreadCountFinance = snapshot.data!.docs
                    .where((doc) => doc['clicked'] == false)
                    .length;
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('type', isEqualTo: 'feedback_noti')
                      .where('candidateID',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    int unreadCountFeedback = snapshot.data!.docs
                        .where((doc) => doc['clicked'] == false)
                        .length;
                    unreadNotificationCount.value = unreadCountEnroll +
                        unreadCountResult +
                        unreadCountFinance +
                        unreadCountFeedback;

                    return Stack(children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationPage(),
                                ));
                          },
                          icon: unreadNotificationCount.value > 0
                              ? Icon(
                                  Icons.notifications,
                                  size: 35,
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                )
                              : Icon(
                                  Icons.notifications_none_outlined,
                                  size: 35,
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                )),
                      if (unreadNotificationCount.value > 0)
                        Positioned(
                          top: 2,
                          right: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadNotificationCount.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ]);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

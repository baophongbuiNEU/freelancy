// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/auth_freelancer/login_or_register_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/user_profile_page.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:freelancer/components/account_compo.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/edit_info_freelancer.dart';

class AccountPageFreelancer extends StatefulWidget {
  const AccountPageFreelancer({super.key});

  @override
  State<AccountPageFreelancer> createState() => _AccountPageFreelancerState();
}

class _AccountPageFreelancerState extends State<AccountPageFreelancer> {
  String userName = "";
  String email = "";
  String avatar = "";

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
        });
      }
    }
  }

  void logout(BuildContext context) {
    final auth = AuthService();
    auth.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginOrRegisterFreelancer()));
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
          }
          return Scaffold(
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            appBar: AppBar(
              title: const Text("Tài khoản"),
              backgroundColor: Colors.white,
              centerTitle: true,
              // leading: IconButton(
              //   onPressed: () {
              //     Navigator.pop(context); // Add this line to add the back button
              //   },
              //   icon: Icon(Icons.arrow_back),
              // ),
              // actions: [
              //   //logout button
              //   IconButton(
              //       onPressed: () => logout(context), icon: const Icon(Icons.logout))
              // ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(),
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 25,
                          ),
                          // user profile image
                          SizedBox(
                            width: 65,
                            height: 65,
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
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                email,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Text(
                              "Cài đặt tài khoản",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        AccountCompo(
                          name: "Chỉnh sửa hồ sơ",
                          icon: Icons.person,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditInfoFreelancer(),
                                ));
                          },
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                        AccountCompo(
                          name: "Đổi mật khẩu",
                          icon: Icons.key,
                          onTap: () {},
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                        AccountCompo(
                          name: "Trạng thái tìm việc",
                          icon: Icons.visibility,
                          onTap: () {},
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                        AccountCompo(
                          name: "Tài chính",
                          icon: Icons.payment_rounded,
                          onTap: () {},
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => logout(context),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Đăng Xuất",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.logout_sharp,
                                color: Colors.red,
                                size: 28,
                              ),
                            ],
                          )),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

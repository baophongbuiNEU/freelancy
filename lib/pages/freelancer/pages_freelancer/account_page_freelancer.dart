// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/account_compo.dart';
import 'package:freelancer/pages/freelancer/auth_freelancer/login_or_register_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/edit_info_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/money_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/project_view_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/user_profile_page.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPageFreelancer extends StatefulWidget {
  const AccountPageFreelancer({super.key});

  @override
  State<AccountPageFreelancer> createState() => _AccountPageFreelancerState();
}

class _AccountPageFreelancerState extends State<AccountPageFreelancer> {
  String userName = "";
  String email = "";
  String avatar = "";
  String role = "";

  @override
  void initState() {
    super.initState();
  }

  void logout(BuildContext context) {
    final auth = AuthService();
    auth.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginOrRegisterFreelancer()));
  }

  // Function to open a URL in a browser
  Future<void> _openWebLink() async {
    final Uri url = Uri.parse('https://freelancer-59466.web.app/');
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens in the default browser
      );
    } else {
      throw 'Could not launch $url';
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
            role = doc['role'] ?? "";
          }
          return Scaffold(
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            appBar: AppBar(
              title: const Text("Tài khoản"),
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _header(context),
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
                              "Quản lý",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        AccountCompo(
                          name: "Quản lý Công việc",
                          icon: Icons.work,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectViewFreelancer(),
                                ));
                          },
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                        AccountCompo(
                          name: "Lịch sử Giao dịch",
                          icon: Icons.payment,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FinancePage(),
                                ));
                          },
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                        // AccountCompo(
                        //   name: "Đổi mật khẩu",
                        //   icon: Icons.key,
                        //   onTap: () {},
                        // ),
                        // Divider(
                        //   height: 1,
                        //   thickness: 1,
                        //   color: Colors.grey[200],
                        // ),
                        // AccountCompo(
                        //   name: "Trạng thái tìm việc",
                        //   icon: Icons.visibility,
                        //   onTap: () {},
                        // ),
                        // Divider(
                        //   height: 1,
                        //   thickness: 1,
                        //   color: Colors.grey[200],
                        // ),
                      ],
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
                        // AccountCompo(
                        //   name: "Quản lý Tài chính",
                        //   icon: Icons.payment_rounded,
                        // onTap: () {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => FinancePage(),
                        //       ));
                        // },
                        // ),
                        // Divider(
                        //   height: 1,
                        //   thickness: 1,
                        //   color: Colors.grey[200],
                        // ),
                        if (role == 'admin')
                          AccountCompo(
                            name: "Đi tới trang Quản trị",
                            icon: Icons.edit,
                            onTap: _openWebLink,
                          ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey[200],
                        ),
                        // AccountCompo(
                        //   name: "Trạng thái tìm việc",
                        //   icon: Icons.visibility,
                        //   onTap: () {},
                        // ),
                        // Divider(
                        //   height: 1,
                        //   thickness: 1,
                        //   color: Colors.grey[200],
                        // ),
                      ],
                    ),
                  ),
                  _logoutBtn(context)
                ],
              ),
            ),
          );
        });
  }

  GestureDetector _logoutBtn(BuildContext context) {
    return GestureDetector(
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
    );
  }

  GestureDetector _header(BuildContext context) {
    return GestureDetector(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}

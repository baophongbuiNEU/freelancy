
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/notfi_compo/enroll_noti.dart';
import 'package:freelancer/components/notfi_compo/feedback_noti.dart';
import 'package:freelancer/components/notfi_compo/finance_noti.dart';
import 'package:freelancer/components/notfi_compo/request_feedback_noti.dart';
import 'package:freelancer/components/notfi_compo/result_noti.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        title: Text('Thông báo'),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Ứng viên'),
              Tab(text: 'Kết quả'),
              Tab(text: 'Tài chính'),
              Tab(text: 'Đánh giá'),
            ],
            labelColor: Color.fromRGBO(67, 101, 222, 1),
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Color.fromRGBO(67, 101, 222, 1),
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListEnroll(),
                _buildListResult(),
                _buildFinanceEnroll(),
                _buildFeedbackEnroll(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildListResult() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: "result_noti")
          .where("candidateID",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Hiện chưa có thông báo'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];

                  return ResultNoti(
                    jobID: post["jobID"],
                    uid: post["employerUID"],
                    clicked: post["clicked"],
                    postID: post.id,
                  );
                }),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return Center(
          child: Text("Hiện chưa có thông báo"),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildListEnroll() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: "enroll_noti")
          .where("employerUID",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];

                  return EnrollNoti(
                    jobID: post["jobID"],
                    uid: post["candidateID"],
                    clicked: post["clicked"],
                    postID: post.id,
                  );
                }),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return Center(
          child: Text("Hiện chưa có thông báo"),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildFinanceEnroll() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: "finance_noti")
          .where("candidateID",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];

                  return FinanceNoti(
                    jobID: post["jobID"],
                    uid: post["employerUID"],
                    clicked: post["clicked"],
                    postID: post.id,
                    salarys: post['salary'],
                  );
                }),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return Center(
          child: Text("Hiện chưa có thông báo"),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildFeedbackEnroll() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: "feedback_noti")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];
                  return post['candidateID'] ==
                          FirebaseAuth.instance.currentUser!.uid
                      ? post['category'] == "feedback"
                          ? FeedbackNoti(
                              jobID: post["jobID"],
                              uid: post["employerUID"],
                              clicked: post["clicked"],
                              postID: post.id,
                            )
                          : SizedBox.shrink()
                      : post['employerUID'] ==
                              FirebaseAuth.instance.currentUser!.uid
                          ? post['category'] == "request"
                              ? RequestFeedbackNoti(
                                  jobID: post["jobID"],
                                  uid: post["candidateID"],
                                  clicked: post["clicked"],
                                  postID: post.id,
                                )
                              : SizedBox.shrink()
                          : SizedBox.shrink();
                }),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return Center(
          child: Text("Hiện chưa có đánh giá nào"),
        );
      },
    );
  }
}

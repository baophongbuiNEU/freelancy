
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/project_enroll_job.dart';
import 'package:freelancer/components/project_user_job.dart';
import 'package:freelancer/services/auth/auth_service.dart';

class ProjectViewFreelancer extends StatefulWidget {
  const ProjectViewFreelancer({super.key});

  @override
  _ProjectViewFreelancerState createState() => _ProjectViewFreelancerState();
}

class _ProjectViewFreelancerState extends State<ProjectViewFreelancer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text(
          'Quản lý công việc',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            labelColor: Color.fromRGBO(67, 101, 222, 1),
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Color.fromRGBO(67, 101, 222, 1),
            controller: _tabController,
            tabs: const [
              Tab(text: 'Công việc của tôi'),
              Tab(text: 'Công việc đã ứng tuyển'),
              // Tab(text: 'Công việc đã hoàn thành'),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyJob(),
                _buildEnrollJob(),
                // _buildDoneJob(),
                // _buildJobList(myJobs, showStatus: true, showEnrolledCount: true),
                // _buildJobList(enrolledJobs, showApplicationStatus: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildMyJob() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .where('uid', isEqualTo: _authService.getCurrentUserID())
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Hiện bạn chưa đăng công việc gì'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];
                  return ProjectUserJob(
                    experience: post["experience"],
                    description: post["description"],
                    enroll_end_time: post["enroll_end_time"],
                    happeningTime: post["happening_time"],
                    location: post["location"],
                    salary: post["salary"],
                    skills: post["skills"],
                    title: post["title"],
                    category: post["category"],
                    uid: post["uid"],
                    timestamp: post["timestamp"],
                    jobID: post["jobID"],
                    enrolls: List<String>.from(
                      post["enrolls"] ?? [],
                    ),
                    accepted: List<String>.from(
                      post["accepted"] ?? [],
                    ),
                  );
                }),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        ));
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildEnrollJob() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .where('enrolls', arrayContains: _authService.getCurrentUserID())
          .orderBy("enroll_timestamps", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Hiện bạn chưa ứng tuyển công việc gì'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];
                  List<dynamic> enrollTimestamps =
                      List<dynamic>.from(post["enroll_timestamps"] ?? []);
                  DateTime? enrollTimestamp;
                  for (var timestamp in enrollTimestamps) {
                    if (timestamp["uid"] == _authService.getCurrentUserID()) {
                      enrollTimestamp = timestamp["timestamp"].toDate();
                      break;
                    }
                  }
                  return ProjectEnrollJob(
                    experience: post["experience"],
                    description: post["description"],
                    enroll_end_time: post["enroll_end_time"],
                    happeningTime: post["happening_time"],
                    location: post["location"],
                    salary: post["salary"],
                    skills: post["skills"],
                    title: post["title"],
                    category: post["category"],
                    uid: post["uid"],
                    timestamp: post["timestamp"],
                    jobID: post["jobID"],
                    enrolls: List<String>.from(
                      post["enrolls"] ?? [],
                    ),
                    accepted: List<String>.from(
                      post["accepted"] ?? [],
                    ),
                    enroll_timestamp: enrollTimestamp,
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

 
}

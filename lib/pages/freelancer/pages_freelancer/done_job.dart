import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/project_enroll_job.dart';

class DoneJob extends StatefulWidget {
  const DoneJob({super.key});

  @override
  State<DoneJob> createState() => _DoneJobState();
}

class _DoneJobState extends State<DoneJob> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        centerTitle: true,
        title: Text(
          "Dự án hoàn thành",
        ),
      ),
      body: _buildEnrollJob(),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildEnrollJob() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .where('category', isEqualTo: 'Done')
          .where('accepted',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Hiện chưa có dự án nào'),
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
                    if (timestamp["uid"] ==
                        FirebaseAuth.instance.currentUser!.uid) {
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
            heightFactor: 10,
            widthFactor: 10,
            child: const CircularProgressIndicator(
              color: Colors.blue,
            ));
      },
    );
  }
}

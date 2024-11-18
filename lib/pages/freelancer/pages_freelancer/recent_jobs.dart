import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/job_list.dart';

class RecentJobs extends StatefulWidget {
  const RecentJobs({super.key});

  @override
  State<RecentJobs> createState() => _RecentJobsState();
}

class _RecentJobsState extends State<RecentJobs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text("Các công việc gần đây"),
      ),
      body: _buildPostListJob(),
    );
  }
}

StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListJob() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection("jobs")
        .where('category', isNotEqualTo: 'Done')
        .where('enroll_end_time', isGreaterThan: Timestamp.now())
        .orderBy("timestamp", descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Text('Hiện chưa có công việc nào'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final post = docs[index];
              final jobID = post["jobID"];

              // Check if the job still exists
              if (jobID != null) {
                return JobList(
                  key: ValueKey(jobID), // Add a unique key for each job item
                  jobID: jobID,
                );
              } else {
                return SizedBox.shrink(); // Placeholder for non-existent job
              }
            },
          ),
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
        ),
      );
    },
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/job_list.dart';

class JobListHomeviewCompo extends StatefulWidget {
  const JobListHomeviewCompo({super.key});

  @override
  State<JobListHomeviewCompo> createState() => _JobListHomeviewCompoState();
}

class _JobListHomeviewCompoState extends State<JobListHomeviewCompo> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .orderBy("timestamp", descending: true)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              shrinkWrap: true, // Set shrinkWrap to true
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                return JobList(
                  experience: post["experience"],
                  description: post["description"],
                  enroll_end_time: post["enroll_end_time"],
                  enroll_start_time: post["enroll_start_time"],
                  happeningTime: post["happening_time"],
                  location: post["location"],
                  requirement: post["requirement"],
                  salary: post["salary"],
                  skills: post["skills"],
                  title: post["title"],
                  category: post["category"],
                  uid: post["uid"],
                  timestamp: post["timestamp"],
                  jobID: post["jobID"],
                  enrolls: List<String>.from(
                      post["enrolls"] ?? [],
                ),accepted: List<String>.from(
                            post["accepted"] ?? [],
                          ),);
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
}

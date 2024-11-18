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
          .where("category", isNotEqualTo: "Done")
          .where('enroll_end_time', isGreaterThan: Timestamp.now())
          .orderBy("timestamp", descending: true)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                return JobList(
                  jobID: post["jobID"],
                );
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/job_list.dart';

class JobListPage extends StatefulWidget {
  final String categoryTitle;

  const JobListPage({super.key, required this.categoryTitle});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 0.980),
      appBar: AppBar(
        title: Text(
          "Gợi ý việc làm ${widget.categoryTitle}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(67, 101, 222, 1),
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.white, size: 28), // Set the icon color to white
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where("category", isEqualTo: widget.categoryTitle)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                    'Hiện chưa có công việc gì đối với lĩnh vực ${widget.categoryTitle}'),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data!.docs[index];
                    return JobList(
                      jobID: post["jobID"],
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
      ),
    );
  }
}

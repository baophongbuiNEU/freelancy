// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/job_details.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_job_details.dart';
import 'package:intl/intl.dart';

class JobList extends StatefulWidget {
  JobList({
    super.key,
    required this.experience,
    required this.description,
    required this.enroll_end_time,
    required this.enroll_start_time,
    required this.happeningTime,
    required this.location,
    required this.requirement,
    required this.salary,
    required this.skills,
    required this.title,
    required this.category,
    required this.uid,
    required this.jobID,
    required this.timestamp,
    required this.enrolls,
    required this.accepted,
  });

  Timestamp enroll_start_time;
  Timestamp enroll_end_time;
  String experience = '';
  Timestamp happeningTime;
  String uid = '';
  String description = '';
  String location = '';
  String requirement = '';
  String salary = '';
  String category = '';
  String skills = '';
  String title = '';
  String jobID = '';
  Timestamp timestamp;
  List<String> enrolls;
  List<String> accepted;

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    DateTime endDate =
        DateTime.parse(widget.enroll_end_time.toDate().toString());
    DateTime currentDate = DateTime.now();
    int daysLeft = endDate.difference(currentDate).inDays;
    int hoursLeft = daysLeft == 0 ? endDate.difference(currentDate).inHours : 0;
    bool isEnrollmentEnded = endDate.isBefore(currentDate);

    final uploadTime =
        DateFormat('dd/MM/yyyy').format(widget.timestamp.toDate());
    String editedSalary = int.parse(widget.salary) > 1000
        ? "${(int.parse(widget.salary) / 1000).toStringAsFixed(3)} VNĐ"
        : "${widget.salary} VNĐ";

    Color borderColor =
        isEnrollmentEnded ? Colors.red : Color.fromRGBO(67, 101, 222, 1);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!.data();
          return Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                if (widget.uid == FirebaseAuth.instance.currentUser!.uid) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetails(
                          jobID: widget.jobID,
                          uid: user["uid"],
                          enrolls: List<String>.from(
                            widget.enrolls ?? [],
                          ),
                          accepted: List<String>.from(
                            widget.accepted ?? [],
                          ),
                        ),
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserJobDetails(
                          jobID: widget.jobID,
                          uid: user["uid"],
                          enrolls: List<String>.from(
                            widget.enrolls ?? [],
                          ),
                        ),
                      ));
                }
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                user!["avatar"],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Text(
                                  widget.title.length > 40
                                      ? "${widget.title.substring(0, 40)}..."
                                      : widget.title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Wrap(
                              children: [
                                Text(
                                  widget.description.length > 50
                                      ? "${widget.description.substring(0, 50)}..."
                                      : widget
                                          .description, // Limit the description to 50 characters
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Wrap(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.location.length > 10
                                            ? "${widget.location.substring(0, 10)}..."
                                            : widget.location,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Wrap(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        editedSalary.length > 8
                                            ? "${editedSalary.substring(0, 8)}..."
                                            : editedSalary,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: PopupMenuButton<String>(
                          color: Colors.white,
                          onSelected: (value) {
                            if (widget.uid ==
                                FirebaseAuth.instance.currentUser!.uid) {
                              // Delete the post
                              FirebaseFirestore.instance
                                  .collection('jobs')
                                  .doc(widget.jobID)
                                  .delete();
                              setState(() {});
                            }
                          },
                          itemBuilder: (context) => [
                            if (widget.uid ==
                                FirebaseAuth.instance.currentUser!.uid)
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Xóa bài đăng'),
                              ),
                          ],
                          icon: Icon(Icons.more_vert),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.grey[300],
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      isEnrollmentEnded
                          ? Text(
                              "Đã hết hạn ứng tuyển",
                              style: TextStyle(color: Colors.grey),
                            )
                          : Row(
                              children: [
                                Text(
                                  "Còn ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                    daysLeft == 0
                                        ? "$hoursLeft giờ"
                                        : "$daysLeft ngày",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text(
                                  " để ứng tuyển",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                      Spacer(),
                      Text(
                        uploadTime.toString().substring(0, 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

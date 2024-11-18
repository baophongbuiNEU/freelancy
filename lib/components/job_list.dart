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
    required this.jobID,
    // required this.uid,
  });

  String jobID = '';
  // String uid = '';

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _jobDataStream;
  // late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;

  @override
  void initState() {
    super.initState();
    _jobDataStream = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID)
        .snapshots();
    // _userDataStream = FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(widget.uid)
    //     .snapshots();
  }

  Future<void> _deleteJob() async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobID)
        .delete();
  }

  Future<void> _deleteNotification() async {
    final jobID = widget.jobID;

    await FirebaseFirestore.instance
        .collection('notifications')
        .where('jobID', isEqualTo: jobID)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

// Define the maximum number of characters based on the device width
    int maxCharacters =
        deviceWidth < 450 ? 6 : 50; // Adjust the value as needed
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _jobDataStream,
      builder: (context, jobSnapshot) {
        // Check if job data is null or deleted
        if (!jobSnapshot.hasData || jobSnapshot.data?.data() == null) {
          return SizedBox.shrink();
        }
        if (jobSnapshot.hasData) {
          final jobData = jobSnapshot.data!.data();
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(jobData!['uid'])
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
                return SizedBox.shrink();
              }
              if (userSnapshot.hasData) {
                final userData = userSnapshot.data!.data();
                DateTime endDate = DateTime.parse(
                    jobData['enroll_end_time'].toDate().toString());
                DateTime currentDate = DateTime.now();
                int daysLeft = endDate.difference(currentDate).inDays;
                int hoursLeft =
                    daysLeft == 0 ? endDate.difference(currentDate).inHours : 0;
                bool isEnrollmentEnded = endDate.isBefore(currentDate);

                // String editedSalary = int.parse(jobData['salary']) > 1000
                //     ? "${(int.parse(jobData['salary']) / 1000).toStringAsFixed(3)} VNĐ"
                //     : "${jobData['salary']} VNĐ";
                bool isDone = jobData['category'] == "Done";

                Color borderColor = isDone == true
                    ? Colors.red
                    : isEnrollmentEnded
                        ? Colors.red
                        : Color.fromRGBO(67, 101, 222, 1);

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
                      if (jobData['uid'] ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetails(
                                jobID: widget.jobID,
                                enrolls: List<String>.from(
                                  jobData['enrolls'] ?? [],
                                ),
                                accepted: List<String>.from(
                                  jobData['accepted'] ?? [],
                                ),
                              ),
                            ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserJobDetails(
                                jobID: widget.jobID,
                                uid: userData["uid"],
                                enrolls: List<String>.from(
                                  jobData['enrolls'] ?? [],
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
                                      userData!["avatar"],
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
                                        jobData['title'].length > 70
                                            ? "${jobData['title'].substring(0, 70)}..."
                                            : jobData['title'],
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
                                        jobData['description'].length > 70
                                            ? "${jobData['description'].substring(0, 70)}..."
                                            : jobData[
                                                'description'], // Limit the description to 50 characters
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          runSpacing: 5,
                                          spacing: 5,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                // jobData['location'].length >
                                                //         maxCharacters
                                                //     ? "${jobData['location'].substring(0, maxCharacters)}..."
                                                //     : jobData['location'],
                                                jobData['location'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            // SizedBox(
                                            //   width: 5,
                                            // ),
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                // editedSalary.length >
                                                //         maxCharacters
                                                //     ? "${editedSalary.substring(0, maxCharacters)}..."
                                                //     : editedSalary,
                                                NumberFormat.currency(
                                                        locale: 'vi_VN',
                                                        symbol: 'đ')
                                                    .format(num.parse(
                                                        jobData['salary'])),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                  if (jobData['uid'] ==
                                      FirebaseAuth.instance.currentUser!.uid) {
                                    // Delete the post
                                    _deleteJob();
                                    _deleteNotification();
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (jobData['uid'] ==
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
                            isDone == true
                                ? Text(
                                    "Công việc đã hoàn thành",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : isEnrollmentEnded
                                    ? Text(
                                        "Đã hết hạn ứng tuyển",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            "Còn ",
                                            style:
                                                TextStyle(color: Colors.grey),
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
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                            Spacer(),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(jobData['timestamp'].toDate()),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else if (userSnapshot.hasError) {
                return Center(
                  child: Text('Error'),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        } else if (jobSnapshot.hasError) {
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

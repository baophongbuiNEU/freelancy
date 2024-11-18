
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/enroll_button.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/confirmation_page_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';

import 'package:intl/intl.dart';

class OtherUserJobDetails extends StatefulWidget {
  final String? jobID;
  final String? uid;
  final List<String> enrolls;

  const OtherUserJobDetails(
      {super.key,
      required this.jobID,
      required this.uid,
      required this.enrolls});

  @override
  State<OtherUserJobDetails> createState() => _OtherUserJobDetailsState();
}

class _OtherUserJobDetailsState extends State<OtherUserJobDetails> {
  bool isEnrolled = false;
  bool isLoading = false;
  bool isAccepted = false;

  void toggleEnroll() async {
    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await Future.delayed(Duration(seconds: 2));

    try {
      // Fetch job details
      DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .doc(widget.jobID)
          .get();

      if (jobSnapshot.exists) {
        Map<String, dynamic> jobDetails =
            jobSnapshot.data() as Map<String, dynamic>;

        // Update isAccepted based on the current user's uid
        isEnrolled = jobDetails['enrolls']
            .contains(FirebaseAuth.instance.currentUser?.uid);

        // Update or remove uid from Firebase
        DocumentReference postRef =
            FirebaseFirestore.instance.collection("jobs").doc(widget.jobID);

        if (isEnrolled) {
          postRef.update({
            'enrolls': FieldValue.arrayRemove(
                [FirebaseAuth.instance.currentUser?.uid]),
            'enroll_timestamps': FieldValue.arrayRemove(
                jobDetails['enroll_timestamps']
                    .where((timestamp) =>
                        timestamp['uid'] ==
                        FirebaseAuth.instance.currentUser?.uid)
                    .toList()),
          });
          // notificationRef.delete();
          // Delete notification
          QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
              .collection("notifications")
              .where('jobID', isEqualTo: widget.jobID)
              .where('candidateID',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('employerUID', isEqualTo: widget.uid)
              .where('type', isEqualTo: 'enroll_noti')
              .get();

          if (notificationSnapshot.docs.isNotEmpty) {
            notificationSnapshot.docs.first.reference.delete();
          }
        } else {
          postRef.update({
            'enrolls':
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
            'enroll_timestamps': FieldValue.arrayUnion([
              {
                'uid': FirebaseAuth.instance.currentUser?.uid,
                'timestamp': Timestamp.now(),
              }
            ]),
          });
          DocumentReference notificationRef = FirebaseFirestore.instance
              .collection("notifications")
              .doc(); // Generate a unique document ID
          notificationRef.set({
            'clicked': false,
            'type': 'enroll_noti',
            'jobID': widget.jobID,
            'candidateID': FirebaseAuth.instance.currentUser!.uid,
            'employerUID': widget.uid,
            'timestamp': Timestamp.now(),
          });
        }
      }

      setState(() {
        isEnrolled = !isEnrolled;
        isLoading = false;
        Navigator.pop(context);
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.active) {
                  if (userSnapshot.hasData) {
                    final user = userSnapshot.data!.data();

                    final jobDetails = snapshot.data!.data();
                    isEnrolled = jobDetails!['enrolls']
                        .contains(FirebaseAuth.instance.currentUser?.uid);
                    isAccepted = jobDetails['accepted']
                        .contains(FirebaseAuth.instance.currentUser?.uid);

                    // Format upload time and enrollment end time
                    final uploadTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['timestamp'].toDate());
                    final enrollEndTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['enroll_end_time'].toDate());
                    final happeningTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['happening_time'].toDate());
                    DateTime currentDate = DateTime.now();
                    DateTime endDate = DateTime.parse(
                        jobDetails['enroll_end_time'].toDate().toString());

                    bool isEnrollmentEnded = endDate.isBefore(currentDate);
                    bool isDone = jobDetails['category'] == "Done";

                    return Scaffold(
                      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                      appBar: AppBar(
                        title: Text('Chi tiết công việc'),
                        centerTitle: true,
                        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                      ),
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: Colors.grey, width: 1)),
                              padding: const EdgeInsets.all(16.0),
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jobDetails['title'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                  SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OtherUserProfilePage(
                                                  userId: widget.uid!),
                                        )),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                user!["avatar"],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          user["name"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  isAccepted == true
                                      ? GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ConfirmationPageFreelancer(
                                                        jobID: widget.jobID,
                                                        uid: widget.uid),
                                              )),
                                          child: Container(
                                            margin: EdgeInsets.only(right: 10),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 25),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Text(
                                              "Xem chi tiết",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        )
                                      : isDone == true
                                          ? Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 25),
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(
                                                "Công việc đã hoàn thành",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            )
                                          : isEnrollmentEnded == true
                                              ? isEnrolled
                                                  ? EnrollButton(
                                                      onTap: toggleEnroll,
                                                      isEnrolled: isEnrolled,
                                                    )
                                                  : Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 25),
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Text(
                                                        "Đã hết thời hạn ứng tuyển",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16),
                                                      ),
                                                    )
                                              : EnrollButton(
                                                  onTap: toggleEnroll,
                                                  isEnrolled: isEnrolled,
                                                ),
                                  SizedBox(height: 30),
                                  Text(
                                    "Thông tin chi tiết",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  _buildInfoRow(Icons.location_on,
                                      jobDetails['location']!),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.attach_money,
                                            size: 25,
                                            color: Color.fromRGBO(
                                                67, 101, 222, 1)),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            NumberFormat.currency(
                                                    locale: 'vi_VN',
                                                    symbol: 'đ')
                                                .format(num.parse(
                                                    jobDetails['salary'])),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoRow(Icons.work,
                                            jobDetails['experience']!),
                                      ),
                                      Expanded(
                                        child: _buildInfoRow(
                                            Icons.person,
                                            "Số lượng tuyển: ${jobDetails['numberCandidates']}"),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoRow(
                                            Icons.calendar_today,
                                            'Ngày đăng: $uploadTime'),
                                      ),
                                      Expanded(
                                          child: _buildInfoRow(Icons.timer,
                                              'Hạn nộp: $enrollEndTime')),
                                    ],
                                  ),
                                  _buildInfoRow(Icons.event,
                                      'Ngày diễn ra: $happeningTime'),
                                  // _buildInfoRow(Icons.business_center, jobDetails['employmentType']!),
                                  // SizedBox(height: 16),
                                  // _buildDateInfo(jobDetails['postedDate']!, jobDetails['applicationDeadline']!),
                                  // SizedBox(height: 24),
                                  SizedBox(height: 20),

                                  _buildSection('Mô tả công việc',
                                      jobDetails['description']!),
                                  SizedBox(height: 15),
                                  _buildSection(
                                      'Yêu cầu', jobDetails['skills']!),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            Center(
                              child: isAccepted == true
                                  ? GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConfirmationPageFreelancer(
                                                    jobID: widget.jobID,
                                                    uid: widget.uid),
                                          )),
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 25),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Text(
                                          "Xem chi tiết",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                      ),
                                    )
                                  : isDone == true
                                      ? Container(
                                          margin: EdgeInsets.only(right: 10),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 25),
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            "Công việc đã hoàn thành",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                        )
                                      : isEnrollmentEnded == true
                                          ? isEnrolled
                                              ? EnrollButton(
                                                  onTap: toggleEnroll,
                                                  isEnrolled: isEnrolled,
                                                )
                                              : Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 25),
                                                  decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Text(
                                                    "Đã hết thời hạn ứng tuyển",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16),
                                                  ),
                                                )
                                          : EnrollButton(
                                              onTap: toggleEnroll,
                                              isEnrolled: isEnrolled,
                                            ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                        child: Text('Không tìm thấy thông tin người dùng'));
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return Center(child: Text('Không tìm thấy chi tiết công việc'));
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Rest of the code...
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 25, color: Color.fromRGBO(67, 101, 222, 1)),
          SizedBox(width: 8),
          Expanded(
              child: Text(
            text,
            style: TextStyle(fontSize: 16),
          )),
        ],
      ),
    );
  }

  // Widget _buildDateInfo(String postedDate, String deadline) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       _buildInfoRow(Icons.calendar_today, 'Đăng ngày: $postedDate'),
  //       _buildInfoRow(Icons.timer, 'Hạn nộp: $deadline'),
  //     ],
  //   );
  // }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(content,
            style: TextStyle(
              fontSize: 16,
            )),
        SizedBox(height: 16),
      ],
    );
  }

  // Widget _buildListSection(String title, List<String> items) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title,
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //       SizedBox(height: 8),
  //       ...items.map((item) => Padding(
  //             padding: const EdgeInsets.only(left: 16, bottom: 4),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text('• ', style: TextStyle(fontSize: 18)),
  //                 Expanded(child: Text(item)),
  //               ],
  //             ),
  //           )),
  //       SizedBox(height: 16),
  //     ],
  //   );
  // }
}

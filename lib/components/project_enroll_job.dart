// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/confirmation_page_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_job_details.dart';

import 'package:intl/intl.dart';

class ProjectEnrollJob extends StatefulWidget {
  ProjectEnrollJob({
    super.key,
    required this.experience,
    required this.description,
    required this.enroll_end_time,
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
    required this.enroll_timestamp,
    required this.accepted,
  });

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

  DateTime? enroll_timestamp;

  @override
  State<ProjectEnrollJob> createState() => _ProjectEnrollJobState();
}

class _ProjectEnrollJobState extends State<ProjectEnrollJob> {
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
    String formattedDateTime =
        '${DateFormat('dd/MM/yyyy').format(widget.enroll_timestamp!)} - ${DateFormat('HH:mm').format(widget.enroll_timestamp!)}';
    bool isDone = widget.category == "Done";

    final uploadTime =
        DateFormat('dd/MM/yyyy').format(widget.timestamp.toDate());
    String editedSalary = int.parse(widget.salary) > 1000
        ? "${(int.parse(widget.salary) / 1000).toStringAsFixed(3)} VNĐ"
        : "${widget.salary} VNĐ";
    final enrollEndTime =
        DateFormat('dd/MM/yyyy HH:mm').format(widget.enroll_end_time.toDate());
    final String totalEnrollment = widget.enrolls.length.toString();
    final happeningTime =
        DateFormat('dd/MM/yyyy HH:mm').format(widget.happeningTime.toDate());

    Color borderColor = isDone ? Colors.green : Color.fromRGBO(67, 101, 222, 1);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!.data();
          bool isCurrentUserAccepted =
              widget.accepted.contains(FirebaseAuth.instance.currentUser!.uid);
          bool isAcceptedHasUser = widget.accepted.isEmpty;

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
              onTap: isCurrentUserAccepted
                  ? () {
                      // Navigate to another page when the Chip is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmationPageFreelancer(
                              jobID: widget.jobID, uid: user!["uid"]),
                        ),
                      );
                    }
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserJobDetails(
                          jobID: widget.jobID,
                          uid: user!["uid"],
                          enrolls: List<String>.from(
                            widget.enrolls ?? [],
                          ),
                        ),
                      )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1200),
                          image: DecorationImage(
                            image: NetworkImage(
                              user!["avatar"],
                            ),
                            fit: BoxFit.cover,
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
                                  widget.title.length > 50
                                      ? "${widget.title.substring(0, 50)}..."
                                      : widget.title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 0,
                            ),
                            Wrap(
                              children: [
                                Text(
                                  user[
                                      "name"], // Limit the description to 50 characters
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 5,
                            // ),
                            // Row(
                            //   children: [
                            //     Wrap(
                            //       children: [
                            //         Container(
                            //           padding: EdgeInsets.all(8),
                            //           decoration: BoxDecoration(
                            //             color: Colors.grey[300],
                            //             borderRadius: BorderRadius.circular(10),
                            //           ),
                            //           child: Text(
                            //             widget.location.length > 10
                            //                 ? "${widget.location.substring(0, 10)}..."
                            //                 : widget.location,
                            //             overflow: TextOverflow.ellipsis,
                            //             style: TextStyle(fontSize: 16),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(
                            //       width: 5,
                            //     ),
                            //     Wrap(
                            //       children: [
                            //         Container(
                            //           padding: EdgeInsets.all(8),
                            //           decoration: BoxDecoration(
                            //             color: Colors.grey[300],
                            //             borderRadius: BorderRadius.circular(10),
                            //           ),
                            //           child: Text(
                            //             editedSalary.length > 8
                            //                 ? "${editedSalary.substring(0, 8)}..."
                            //                 : editedSalary,
                            //             overflow: TextOverflow.ellipsis,
                            //             style: TextStyle(fontSize: 16),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Chip(
                        padding: EdgeInsets.all(0),
                        side: BorderSide.none,
                        label: Text(
                          isAcceptedHasUser == false
                              ? isCurrentUserAccepted
                                  ? "Trúng tuyển"
                                  : "Từ chối"
                              : "Đã ứng tuyển",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        backgroundColor: isAcceptedHasUser == false
                            ? isCurrentUserAccepted
                                ? Colors.green
                                : Colors.red
                            : Color.fromRGBO(67, 101, 222, 1),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget
                        .description, // Limit the description to 50 characters
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.location_on, widget.location),
                  _buildInfoRow(Icons.calendar_today, 'Ngày đăng: $uploadTime'),
                  _buildInfoRow(Icons.timer, 'Hạn nộp: $enrollEndTime'),
                  _buildInfoRow(Icons.event, 'Ngày diễn ra: $happeningTime'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                  ),
                  isCurrentUserAccepted && isDone == true
                      ? Row(
                          children: const [
                            Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Công việc đã hoàn thành",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.green),
                            ),
                          ],
                        )
                      : isCurrentUserAccepted == true
                          ? Row(
                              children: const [
                                Icon(
                                  Icons.work_outline_outlined,
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Công việc đang trong quá trình thực hiện",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(67, 101, 222, 1)),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Đã ứng tuyển vào: $formattedDateTime",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(67, 101, 222, 1)),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 25, color: Color.fromRGBO(67, 101, 222, 1)),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/job_details.dart';
import 'package:intl/intl.dart';

class ProjectUserJob extends StatefulWidget {
  ProjectUserJob({
    super.key,
    required this.experience,
    required this.description,
    required this.enroll_end_time,
    required this.happeningTime,
    required this.location,
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

  Timestamp enroll_end_time;
  String experience = '';
  Timestamp happeningTime;
  String uid = '';
  String description = '';
  String location = '';
  String salary = '';
  String category = '';
  String skills = '';
  String title = '';
  String jobID = '';
  Timestamp timestamp;
  List<String> enrolls;
  List<String> accepted;

  @override
  State<ProjectUserJob> createState() => _ProjectUserJobState();
}

class _ProjectUserJobState extends State<ProjectUserJob> {
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
    bool isDone = widget.category == "Done";
    bool isAccepted = widget.accepted.isNotEmpty;
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
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetails(
                      jobID: widget.jobID,
                      enrolls: List<String>.from(
                        widget.enrolls ?? [],
                      ),
                      accepted: List<String>.from(
                        widget.accepted ?? [],
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
                                  user["name"],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Chip(
                        side: BorderSide.none,
                        padding: EdgeInsets.all(0),
                        label: Text(
                          isDone == true
                              ? 'Đã hoàn thành'
                              : isEnrollmentEnded == false
                                  ? isAccepted
                                      ? 'Đang thực hiện'
                                      : 'Đang mở'
                                  : 'Đã đóng',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        backgroundColor: isDone == true
                            ? Colors.green
                            : isEnrollmentEnded == false
                                ? Color.fromRGBO(67, 101, 222, 1)
                                : Colors.red,
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
                  Row(
                    children: [
                      Icon(Icons.person,
                          size: 25, color: Color.fromRGBO(67, 101, 222, 1)),
                      SizedBox(width: 8),
                      Text(
                        'Số người ứng tuyển: $totalEnrollment',
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
          child: Text("Hiện chưa có công việc nào"),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/confirmation_page_employer.dart';
import 'package:intl/intl.dart';

class MarkDoneNoti extends StatefulWidget {
  final String? jobID;
  final String? uid;
  // final void Function()? onTap;
  final bool? clicked;
  final String? postID;

  const MarkDoneNoti({
    super.key,
    required this.jobID,
    required this.uid,
    // required this.onTap,
    required this.clicked,
    required this.postID,
  });

  @override
  State<MarkDoneNoti> createState() => _MarkDoneNotiState();
}

class _MarkDoneNotiState extends State<MarkDoneNoti> {
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
                    // bool isCurrentUserAccepted = jobDetails!["accepted"]
                    //     .contains(FirebaseAuth.instance.currentUser!.uid);

                    // isAccepted = jobDetails!['accepted']
                    //     .contains(FirebaseAuth.instance.currentUser?.uid);

                    // Format upload time and enrollment end time
                    final uploadTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails!['timestamp'].toDate());
                    final enrollEndTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['enroll_end_time'].toDate());
                    final happeningTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['happening_time'].toDate());
                    final timestamps = (jobDetails['enroll_timestamps'] as List)
                        .map((item) => (item as Map)['timestamp'] as Timestamp)
                        .toList();

                    final latestTimestamp = timestamps.last;
                    final formattedTimestamp = latestTimestamp != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(latestTimestamp.toDate())
                        : 'N/A';

                    return GestureDetector(
                      onTap: () {
                        DocumentReference notificationRef = FirebaseFirestore
                            .instance
                            .collection("notifications")
                            .doc(widget.postID);
                        notificationRef.update({
                          'clicked': true,
                        });
                        // isCurrentUserAccepted == true
                        //     ?
                        //     // Navigate to another page when the Chip is tapped
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmationPageEmployer(
                                jobID: widget.jobID,
                                uid: widget.uid,
                              ),
                            ));
                        //     : Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => OtherUserJobDetails(
                        //             jobID: widget.jobID,
                        //             uid: user["uid"],
                        //             enrolls: List<String>.from(
                        //               jobDetails["enrolls"] ?? [],
                        //             ),
                        //           ),
                        //         ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 1.5),
                            color: widget.clicked == false
                                ? Color.fromARGB(255, 237, 247, 255)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(120),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Công việc hoàn thành",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Wrap(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "${user['name']} đã hoàn thành công việc ",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                TextSpan(
                                                  text: jobDetails["title"],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                                TextSpan(
                                                  text: ". Bấm vào để xác nhận",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                      // Wrap(
                                      //   children: [
                                      //     Chip(
                                      //         padding: EdgeInsets.all(0),
                                      //         side: BorderSide.none,
                                      //         label: Text(
                                      //           isCurrentUserAccepted
                                      //               ? "Trúng tuyển"
                                      //               : "Từ chối",
                                      //           style: TextStyle(
                                      //               color: Colors.white,
                                      //               fontSize: 15),
                                      //         ),
                                      //         backgroundColor:
                                      //             isCurrentUserAccepted
                                      //                 ? Colors.green
                                      //                 : Colors.red
                                      //         // : Color.fromRGBO(67, 101, 222, 1),
                                      //         ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: PopupMenuButton<String>(
                                    color: Colors.white,
                                    onSelected: (value) {
                                      // Delete the post
                                      FirebaseFirestore.instance
                                          .collection('notifications')
                                          .doc(widget.postID)
                                          .delete();
                                      setState(() {});
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Xóa thông báo'),
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
                            Wrap(
                              children: [
                                Text(formattedTimestamp,
                                    style: TextStyle(color: Colors.grey)),
                              ],
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(67, 101, 222, 1),
                    ),
                  );
                }
              },
            );
          } else {
            return Center(child: Text('Không tìm thấy chi tiết công việc'));
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(67, 101, 222, 1),
            ),
          );
        }
      },
    );
  }
}

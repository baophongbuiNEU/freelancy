import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/feedback_viewer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/chat_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';

import 'package:intl/intl.dart';

class ConfirmationPageFreelancer extends StatefulWidget {
  final String? jobID;
  final String? uid;
  const ConfirmationPageFreelancer(
      {super.key, required this.jobID, required this.uid});

  @override
  State<ConfirmationPageFreelancer> createState() =>
      _ConfirmationPageFreelancerState();
}

class _ConfirmationPageFreelancerState
    extends State<ConfirmationPageFreelancer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> _deleteNotification() async {
    final jobID = widget.jobID;
    final candidateID = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('notifications')
        .where('jobID', isEqualTo: jobID)
        .where('candidateID', isEqualTo: candidateID)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> notificationExists(
      String? clientName, String? jobID, String? employerUID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('clientName', isEqualTo: clientName)
        .where('jobID', isEqualTo: jobID)
        .where('employerUID', isEqualTo: employerUID)
        .where('type', isEqualTo: "finance_noti")
        .get();

    return querySnapshot.docs.isNotEmpty;
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
                    return StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, currentUserSnapshot) {
                        if (currentUserSnapshot.connectionState ==
                            ConnectionState.active) {
                          if (currentUserSnapshot.hasData) {
                            return StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('feedbacks')
                                  .where('jobID', isEqualTo: widget.jobID)
                                  .snapshots(),
                              builder: (context, notificationsSnapshot) {
                                if (notificationsSnapshot.connectionState ==
                                    ConnectionState.active) {
                                  if (notificationsSnapshot.hasData) {
                                    final user = userSnapshot.data!.data();
                                    final currentUser =
                                        currentUserSnapshot.data!.data();
                                    final jobDetails = snapshot.data!.data();
                                    final notifications = notificationsSnapshot
                                        .data!.docs
                                        .map((doc) => doc.data())
                                        .toList();
                                    bool isFeedback = false;

                                    notifications.isEmpty
                                        ? isFeedback = false
                                        : isFeedback = true;
                                    bool isSend = false;
                                    jobDetails!['sent'] == true
                                        ? isSend = true
                                        : isSend = false;

                                    // Format upload time and enrollment end time
                                    final uploadTime =
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                            jobDetails['timestamp'].toDate());
                                    final enrollEndTime =
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                            jobDetails['enroll_end_time']
                                                .toDate());
                                    final happeningTime =
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                            jobDetails['happening_time']
                                                .toDate());
                                    final acceptedTimestamps =
                                        jobDetails['accepted_timestamps']
                                            as List<dynamic>;
                                    for (final timestampData
                                        in acceptedTimestamps) {
                                      final timestamp =
                                          timestampData['timestamp']
                                              as Timestamp;
                                      final dateTime = timestamp.toDate();
                                      final formattedTimestamp =
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(dateTime);
                                    }
                                    final timestamps =
                                        (jobDetails['accepted_timestamps']
                                                as List)
                                            .map((item) =>
                                                (item as Map)['timestamp']
                                                    as Timestamp)
                                            .toList();
                                    bool isDone =
                                        jobDetails['category'] == "Done";

                                    final latestTimestamp = timestamps.last;
                                    final formattedTimestamp =
                                        latestTimestamp != null
                                            ? DateFormat('dd/MM/yyyy HH:mm')
                                                .format(
                                                    latestTimestamp.toDate())
                                            : 'N/A';

                                    return Scaffold(
                                      backgroundColor:
                                          Color.fromRGBO(250, 250, 250, 1),
                                      appBar: AppBar(
                                        title: Text("Xác nhận công việc"),
                                        centerTitle: true,
                                        backgroundColor:
                                            Color.fromRGBO(250, 250, 250, 1),
                                        actions: [
                                          if (isDone == false)
                                            Expanded(
                                              flex: 0,
                                              child: PopupMenuButton<String>(
                                                color: Colors.white,
                                                onSelected: (value) async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Yêu cầu hủy công việc"),
                                                          content: Text(
                                                              "Bạn có chắc muốn hủy không?"),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                'Đóng',
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            67,
                                                                            101,
                                                                            222,
                                                                            1),
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                {
                                                                  // Delete the post
                                                                  DocumentReference
                                                                      postRef =
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              "jobs")
                                                                          .doc(widget
                                                                              .jobID);
                                                                  postRef
                                                                      .update({
                                                                    'accepted':
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid
                                                                    ]),
                                                                    'accepted_timestamps': FieldValue.arrayRemove(acceptedTimestamps
                                                                        .where((timestamp) =>
                                                                            timestamp['uid'] ==
                                                                            FirebaseAuth.instance.currentUser!.uid)
                                                                        .toList()),
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                  _deleteNotification();
                                                                }
                                                              },
                                                              child: Text(
                                                                'Chắc chắn',
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            67,
                                                                            101,
                                                                            222,
                                                                            1),
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child:
                                                        Text('Hủy công việc'),
                                                  ),
                                                ],
                                                icon: Icon(Icons.more_vert),
                                              ),
                                            )
                                        ],
                                      ),
                                      body: SingleChildScrollView(
                                        child: SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Xác nhận thỏa thuận công việc',
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Hai bên đã đồng ý về các điều khoản của công việc',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600]),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Spacer(),
                                                          Expanded(
                                                            flex: 4,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  width: 65,
                                                                  height: 65,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                      user![
                                                                          "avatar"],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  user["name"],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Text(
                                                                    'Tuyển dụng',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Column(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 32),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                  'Đã thỏa thuận',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          600])),
                                                            ],
                                                          ),
                                                          Spacer(),
                                                          Expanded(
                                                            flex: 4,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  width: 65,
                                                                  height: 65,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                      currentUser![
                                                                          "avatar"],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  currentUser[
                                                                      "name"],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Text(
                                                                    'Ứng Viên',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Spacer(),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                        height: 25,
                                                      ),
                                                      _buildSection(
                                                          'Tiêu đề công việc',
                                                          jobDetails['title']!),
                                                      _buildInfoRow(
                                                          Icons.location_on,
                                                          jobDetails[
                                                              'location']!),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .attach_money,
                                                                size: 25,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        67,
                                                                        101,
                                                                        222,
                                                                        1)),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                NumberFormat.currency(
                                                                        locale:
                                                                            'vi_VN',
                                                                        symbol:
                                                                            'đ')
                                                                    .format(num.parse(
                                                                        jobDetails[
                                                                            'salary'])),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      _buildInfoRow(
                                                          Icons.work,
                                                          jobDetails[
                                                              'experience']!),
                                                      // Row(
                                                      //   children: [
                                                      //     Expanded(
                                                      //       child: _buildInfoRow(
                                                      //           Icons.calendar_today,
                                                      //           'Ngày đăng: $uploadTime'),
                                                      //     ),
                                                      //     Expanded(
                                                      //         child: _buildInfoRow(
                                                      //             Icons.timer,
                                                      //             'Hạn nộp: $enrollEndTime')),
                                                      //   ],
                                                      // ),
                                                      _buildInfoRow(Icons.event,
                                                          'Ngày diễn ra: $happeningTime'),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 25),
                                                _buildSection('Mô tả công việc',
                                                    jobDetails['description']!),
                                                SizedBox(height: 15),
                                                _buildSection('Yêu cầu',
                                                    jobDetails['skills']!),
                                                const SizedBox(height: 24),
                                                _buildAgreementDate(
                                                    formattedTimestamp),
                                                const SizedBox(height: 24),
                                                _buildActions(
                                                    user["name"],
                                                    user["uid"],
                                                    user["avatar"],
                                                    () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              OtherUserProfilePage(
                                                                  userId: user[
                                                                      "uid"]),
                                                        )),
                                                    isFeedback,
                                                    jobDetails['title'],
                                                    isDone,
                                                    acceptedTimestamps,
                                                    isSend),
                                                SizedBox(height: 25),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Center(child: Text(''));
                                  }
                                } else {
                                  return Center(
                                    child: Text(''),
                                  );
                                }
                              },
                            );
                          } else {
                            return Center(child: Text(''));
                          }
                        } else {
                          return Center(
                            child: Text(''),
                          );
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: Text(''),
                    );
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return Center(child: Text(''));
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSection(String title, String content) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(content,
              style: TextStyle(
                fontSize: 16,
              )),
          SizedBox(height: 16),
        ],
      ),
    );
  }

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

  Widget _buildAgreementDate(String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Thỏa thuận này được xác nhận vào ngày: $time',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(
    String userName,
    String userID,
    String userAvatar,
    void Function()? onTap,
    bool isFeedback,
    String jobTitle,
    bool isDone,
    List<dynamic> acceptedTimestamps,
    bool isSend,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                    receiverEmail: userName,
                    receiverID: userID,
                    avatar: userAvatar,
                    onTap: onTap),
              )),
          style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(67, 101, 222, 1)),
          child: Text(
            'Liên hệ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
            onPressed: () async {
              bool exists = await notificationExists(
                FirebaseAuth.instance.currentUser!.uid,
                widget.jobID,
                widget.uid,
              );
              isDone == true
                  ? isFeedback == true
                      ? showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Xem đánh giá"),
                              content: FeedbackViewer(
                                employerID: userID,
                                jobID: widget.jobID!,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                        color: Color.fromRGBO(67, 101, 222, 1),
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Đã yêu cầu đánh giá"),
                              content: Text("Yêu cầu đánh giá thành công"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    DocumentReference notiPlus = FirebaseFirestore
                                        .instance
                                        .collection("notifications")
                                        .doc(); // Generate a unique document ID
                                    notiPlus.set({
                                      'clicked': false,
                                      'category': "request",
                                      'type': 'feedback_noti',
                                      'clientName': userName,
                                      'jobTitle': jobTitle,
                                      'jobID': widget.jobID,
                                      'candidateID': FirebaseAuth
                                          .instance.currentUser!.uid,
                                      'employerUID': widget.uid,
                                      'timestamp': Timestamp.now(),
                                    });
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                        color: Color.fromRGBO(67, 101, 222, 1),
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          })
                  : isSend == false
                      ? showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Đánh dấu là đã hoàn thành"),
                              content: Text(
                                "Bạn có chắc đã hoàn thành công việc không?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Đóng',
                                    style: TextStyle(
                                        color: Color.fromRGBO(67, 101, 222, 1),
                                        fontSize: 16),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    {
                                      DocumentReference notificationRef =
                                          FirebaseFirestore.instance
                                              .collection("notifications")
                                              .doc(); // Generate a unique document ID
                                      notificationRef.set({
                                        'clicked': false,
                                        'category': 'markDone',
                                        'type': 'enroll_noti',
                                        'jobID': widget.jobID,
                                        'candidateID': FirebaseAuth
                                            .instance.currentUser!.uid,
                                        'employerUID': widget.uid,
                                        'timestamp': Timestamp.now(),
                                      });
                                      DocumentReference jobRef = FirebaseFirestore
                                          .instance
                                          .collection("jobs")
                                          .doc(widget
                                              .jobID); // Generate a unique document ID
                                      jobRef.update({
                                        'sent': true,
                                      });
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            title:
                                                Text("Đã gửi yêu cầu xác nhận"),
                                            content: Text(
                                              "Người tuyển dụng sẽ xác nhận yêu cầu của bạn sớm thôi",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Đóng',
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          67, 101, 222, 1),
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Chắc chắn',
                                    style: TextStyle(
                                        color: Color.fromRGBO(67, 101, 222, 1),
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          })
                      : () {};
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: isDone == true
                    ? isFeedback == true
                        ? Colors.green
                        : Color.fromRGBO(67, 101, 222, 1)
                    : isSend == true
                        ? Colors.green
                        : Color.fromRGBO(67, 101, 222, 1)),
            child: isDone == true
                ? isFeedback == true
                    ? Text(
                        'Xem đánh giá',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : Text(
                        'Yêu cầu đánh giá',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                : isSend == true
                    ? Text(
                        "Đang chờ xác nhận",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : Text(
                        "Đánh dấu là đã hoàn thành",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
      ],
    );
  }
}

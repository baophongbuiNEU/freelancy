import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/user_tile_job_confirm.dart';
import 'package:freelancer/components/user_tile_job_detail.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:intl/intl.dart';

class JobDetails extends StatefulWidget {
  final String? jobID;
  final String? uid;
  final List<String> enrolls;
  final List<String> accepted;

  const JobDetails(
      {super.key,
      required this.jobID,
      required this.uid,
      required this.enrolls,
      required this.accepted});

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  bool isAccepted = false;
  bool isLoading = false;

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

                    isAccepted = jobDetails!['accepted']
                        .contains(FirebaseAuth.instance.currentUser?.uid);

                    // Format upload time and enrollment end time
                    final uploadTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['timestamp'].toDate());
                    final enrollEndTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['enroll_end_time'].toDate());
                    final happeningTime = DateFormat('dd/MM/yyyy HH:mm')
                        .format(jobDetails['happening_time'].toDate());

                    return Scaffold(
                      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                      appBar: AppBar(
                        title: Text('Chi tiết công việc'),
                        centerTitle: true,
                        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                        actions: [
                          Expanded(
                            flex: 0,
                            child: PopupMenuButton<String>(
                              color: Colors.white,
                              onSelected: (value) {
                                // Delete the post
                                FirebaseFirestore.instance
                                    .collection('jobs')
                                    .doc(widget.jobID)
                                    .delete();
                                Navigator.pop(context);
                              },
                              itemBuilder: (context) => [
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
                                  Row(
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
                                            int.parse(jobDetails['salary']) >
                                                    1000
                                                ? "${(int.parse(jobDetails['salary']) / 1000).toStringAsFixed(3)} VNĐ"
                                                : "${jobDetails['salary']} VNĐ",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildInfoRow(
                                      Icons.work, jobDetails['experience']!),
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
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Danh sách những người đã ứng tuyển",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            _buildSection(
                                jobDetails['description']!,
                                enrolledUsers: jobDetails['enrolls'],
                                jobDetails['accepted'].contains(widget.uid)),
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

  // Widget _buildSection(
  //   String title,
  //   String content,
  //   bool isAccepted, {
  //   List<dynamic>? enrolledUsers,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if (enrolledUsers != null && enrolledUsers.isNotEmpty)
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(height: 10),
  //             StreamBuilder<List<Map<String, dynamic>>>(
  //               stream: _fetchEnrolledUsersStream(enrolledUsers),
  //               builder: (context, snapshot) {
  //                 if (snapshot.hasData) {
  //                   if (snapshot.data!.isEmpty) {
  //                     return Text(
  //                       "Hiện chưa có ai ứng tuyển!",
  //                       style: TextStyle(
  //                           fontWeight: FontWeight.bold, fontSize: 18),
  //                     );
  //                   } else {
  //                     return Column(
  //                       children: snapshot.data!
  //                           .map((user) => Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 15),
  //                                 child: UserTileJobDetail(
  //                                   onTap: () => Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (context) =>
  //                                             OtherUserProfilePage(
  //                                                 userId: user["uid"]),
  //                                       )),
  //                                   userName: user["name"],
  //                                   avatar: user["avatar"],
  //                                   email: user["email"],
  //                                   jobID: widget.jobID,
  //                                   uid: user["uid"],
  //                                   isAccepted: isAccepted,
  //                                   accepts: List<String>.from(
  //                                     widget.accepted ?? [],
  //                                   ),
  //                                 ),
  //                               ))
  //                           .toList(),
  //                     );
  //                   }
  //                 } else if (snapshot.hasError) {
  //                   return Text('Error: ${snapshot.error}');
  //                 } else {
  //                   return Center(child: CircularProgressIndicator());
  //                 }
  //               },
  //             ),
  //             SizedBox(height: 16),
  //           ],
  //         ),
  //     ],
  //   );
  // }

  Widget _buildSection(
    String content,
    bool isAccepted, {
    List<dynamic>? enrolledUsers,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        if (widget.accepted.isNotEmpty)
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fetchAcceptedUsersStream(widget.accepted),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Hiện chưa có ai chấp nhận!",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                  );
                } else {
                  return Column(
                    children: snapshot.data!
                        .map((user) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: UserTileJobConfirm(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OtherUserProfilePage(
                                              userId: user["uid"]),
                                    )),
                                userName: user["name"],
                                avatar: user["avatar"],
                                email: user["email"],
                                jobID: widget.jobID,
                                uid: user["uid"],
                                isAccepted: isAccepted,
                                accepts: List<String>.from(
                                  widget.accepted ?? [],
                                ),
                              ),
                            ))
                        .toList(),
                  );
                }
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )
        else
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fetchEnrolledUsersStream(enrolledUsers!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Text(
                    "Hiện chưa có ai ứng tuyển!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  );
                } else {
                  return Column(
                    children: snapshot.data!
                        .map((user) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: UserTileJobDetail(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OtherUserProfilePage(
                                              userId: user["uid"]),
                                    )),
                                userName: user["name"],
                                avatar: user["avatar"],
                                email: user["email"],
                                jobID: widget.jobID,
                                uid: user["uid"],
                                isAccepted: isAccepted,
                                accepts: List<String>.from(
                                  widget.accepted ?? [],
                                ),
                              ),
                            ))
                        .toList(),
                  );
                }
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        SizedBox(height: 16),
      ],
    );
  }

  Stream<List<Map<String, dynamic>>> _fetchEnrolledUsersStream(
      List<dynamic> uids) async* {
    List<Map<String, dynamic>> enrolledUsers = [];

    for (String uid in uids) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        enrolledUsers.add(userData);
      }
    }

    yield enrolledUsers;
  }

  Stream<List<Map<String, dynamic>>> _fetchAcceptedUsersStream(
      List<dynamic> uids) async* {
    List<Map<String, dynamic>> acceptedUsers = [];

    for (String uid in uids) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists && widget.accepted.contains(userSnapshot.id)) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        acceptedUsers.add(userData);
      }
    }

    yield acceptedUsers;
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

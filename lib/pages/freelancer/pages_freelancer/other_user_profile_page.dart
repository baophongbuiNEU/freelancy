import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/image_viewer.dart';
import 'package:freelancer/components/job_list.dart';
import 'package:freelancer/components/user_post_profile.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/chat_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/user_profile_page.dart';

import 'package:intl/intl.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  const OtherUserProfilePage({super.key, required this.userId});

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userData;
  List<String> _skills = [];
  List<dynamic> experiences = [];
  dynamic jobName;
  dynamic jobDescription;
  dynamic period;
  @override
  void initState() {
    super.initState();
    _userData =
        FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Hồ sơ', style: TextStyle(color: Colors.black)),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.share, color: Colors.black),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!.data();
            _skills = List<String>.from(
              user!['skills'] ?? [],
            );
            experiences = user['experiences'] as List<dynamic>;
            for (final experience in experiences) {
              jobName = experience['jobName'] ?? "";
              jobDescription = experience['jobDescription'] ?? "";
              period = experience['period'] ?? "";
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(user),
                  SizedBox(height: 16),
                  _buildSkillsCard(user),
                  SizedBox(height: 16),
                  _buildExperienceForm(jobName, jobDescription, period),
                  SizedBox(height: 16),
                  _buildFeedbackForm(),
                  SizedBox(height: 16),
                  _buildJobs(),
                  SizedBox(height: 16),
                  _buildPosts(),
                ],
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
      ),
    );
  }

  Container _buildJobs() {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16, top: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Công việc',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // IconButton(
                //   icon: Icon(Icons.edit, size: 20),
                //   onPressed: () {
                //     setState(() {
                //       _isEditing = !_isEditing;
                //     });
                //   },
                // ),
              ],
            ),
          ),
          _buildPostListJob(),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListJob() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .where('uid', isEqualTo: widget.userId)
          .where("category", isNotEqualTo: "Done")

          // .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Text('Hiện chưa có công việc nào'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: ListView.builder(
                shrinkWrap: true, // Makes ListView take up only needed space
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];
                  if (post["uid"] == FirebaseAuth.instance.currentUser!.uid) {}
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
    );
  }

  Container _buildPosts() {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16, top: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Bài viết',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // IconButton(
                //   icon: Icon(Icons.edit, size: 20),
                //   onPressed: () {
                //     setState(() {
                //       _isEditing = !_isEditing;
                //     });
                //   },
                // ),
              ],
            ),
          ),
          _buildPostListCandidate(),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListCandidate() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('uid', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Text('Hiện chưa có bài viết gì'),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true, // Makes ListView take up only needed space
            physics:
                ClampingScrollPhysics(), // Allows SingleChildScrollView to handle scrolling
            itemBuilder: (context, index) {
              final post = snapshot.data!.docs[index];
              return UserPostProfile(
                content: post["content"],
                uid: post["uid"],
                image: post["image"],
                timestamp: post["timestamp"],
                postId: post.id,
                likes: List<String>.from(post["likes"] ?? []),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error"),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade500, Colors.blue.shade600],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 20,
                width: 130,
                height: 130,
                child: GestureDetector(
                  onTap: () {
                    user['avatar'] != ""
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ImageViewer(image: user['avatar'])))
                        : {};
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // Add this line
                    child: CircleAvatar(
                      radius: 60, // Reduce the radius
                      backgroundImage: NetworkImage(user['avatar']),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(user['position'],
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 17)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.message,
                          size: 16,
                          color: Color.fromRGBO(67, 101, 222, 1),
                        ),
                        label: Text('Liên hệ',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                fontSize: 16)),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverEmail: user['name'],
                                receiverID: user['uid'],
                                avatar: user['avatar'],
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OtherUserProfilePage(
                                                userId: user["uid"],
                                              )));
                                },
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  user['bio'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.email, user['email']),
                _buildInfoRow(Icons.phone, user['phoneNumber']),
                _buildInfoRow(Icons.location_on, user['address']),
                _buildInfoRow(Icons.business, user['city']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue.shade500),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Kỹ năng',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExperienceForm(
      dynamic jobName, dynamic jobDescription, dynamic period) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('Kinh nghiệm',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(experiences.length, (index) {
                return _buildExperienceItem(
                    experiences[index]['jobName'],
                    experiences[index]['jobDescription'],
                    experiences[index]['period'],
                    index);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceItem(
      String title, String company, String period, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(company, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        SizedBox(height: 2),
        Text(period, style: TextStyle(fontSize: 16, color: Colors.grey)),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeedbackForm() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedbacks')
          .where('customerID', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final feedbacks = snapshot.data!.docs;

        if (feedbacks.isEmpty) {
          if (feedbacks.isEmpty) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Đánh giá',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(child: Text("Hiện chưa có đánh giá")),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        return Container(
          margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đánh giá',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                ...feedbacks.map((feedback) => _buildFeedbackItem(feedback)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackItem(QueryDocumentSnapshot<Object?> feedback) {
    final employerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(feedback['employerUID']);

    return StreamBuilder<DocumentSnapshot>(
      stream: employerRef.snapshots(),
      builder: (context, employerSnapshot) {
        if (employerSnapshot.hasError) {
          return Text('Error fetching employer data');
        }

        if (!employerSnapshot.hasData) {
          return Text('Loading employer data');
        }

        final employer = employerSnapshot.data!;
        final employerName = employer['name'] ?? '';
        final employerAvatar = employer['avatar'] ?? '';

        return Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => feedback['employerUID'] ==
                        FirebaseAuth.instance.currentUser!.uid
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(),
                        ))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserProfilePage(
                              userId: feedback['employerUID']),
                        )),
                child: Row(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(employerAvatar),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employerName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(DateFormat('dd/MM/yyyy')
                            .format(feedback['timestamp'].toDate())),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Text(feedback['rating'].toString())
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 7),
              Text(
                feedback['feedback'],
                style: TextStyle(fontSize: 16),
              ),
              // Divider(
              //   color: Colors.grey,
              //   thickness: 0.5,
              // ),
            ],
          ),
        );
      },
    );
  }
}

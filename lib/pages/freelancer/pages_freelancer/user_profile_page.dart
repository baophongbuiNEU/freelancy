import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/image_viewer.dart';
import 'package:freelancer/components/job_list.dart';
import 'package:freelancer/components/user_post_profile.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/edit_info_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/upload_jobs.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/upload_post.dart';

import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = "";
  String email = "";
  String avatar = "";
  String city = "";
  String phoneNumber = "";
  String address = "";
  String position = "";
  String bio = "";
  TextEditingController skillController = TextEditingController();
  List<String> _skills = [];
  final String _jobName = '';
  final String _jobDescription = '';
  final String _period = '';
  TextEditingController jobNameController = TextEditingController();
  TextEditingController jobDescriptionController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  bool _isEditing = false;
  bool _isExeriencing = false;
  List<dynamic> experiences = [];
  dynamic jobName;
  dynamic jobDescription;
  dynamic period;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userName = doc['name'] ?? "";
          email = doc['email'] ?? "";
          avatar = doc['avatar'] ?? "";
          city = doc['city'] ?? "";
          phoneNumber = doc['phoneNumber'] ?? "Chưa cập nhật";
          address = doc['address'] ?? "Chưa cập nhật";
          position = doc['position'] ?? "Chưa cập nhật";
          bio = doc['bio'] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final doc = snapshot.data!;
            userName = doc['name'] ?? "";
            email = doc['email'] ?? "";
            avatar = doc['avatar'] ?? "";
            bio = doc['bio'] ?? "";
            address = doc['address'];
            city = doc['city'] ?? "";
            phoneNumber = doc['phoneNumber'] ?? "Chưa cập nhật";
            position = doc['position'] ?? "Chưa cập nhật";
            _skills = List<String>.from(
              doc['skills'] ?? [],
            );
            experiences = doc['experiences'] as List<dynamic>;

            // Iterate over the experiences list
            for (final experience in experiences) {
              jobName = experience['jobName'] ?? "";
              jobDescription = experience['jobDescription'] ?? "";
              period = experience['period'] ?? "";
            }
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title:
                  Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.black)),
              // actions: [
              //   IconButton(
              //     icon: Icon(Icons.share, color: Colors.black),
              //     onPressed: () {},
              //   ),
              // ],
            ),
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(),
                  SizedBox(height: 16),
                  _buildSkillsCard(),
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
            ),
          );
        });
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
            padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Công việc',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadJobs(),
                        ));
                  },
                ),
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
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          // .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Hiện chưa có công việc nào'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
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
            padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bài viết',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add, size: 25),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadPost(
                            gallery: true,
                            selectedRole: "Ứng viên",
                          ),
                        ));
                  },
                ),
              ],
            ),
          ),
          _buildPostListCandidate(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
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
                    avatar != ""
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ImageViewer(image: avatar)))
                        : {};
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // Add this line
                    child: CircleAvatar(
                      radius: 60, // Reduce the radius
                      backgroundImage: NetworkImage(avatar),
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
                            userName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(position,
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
                          Icons.edit,
                          size: 16,
                          color: Colors.black,
                        ),
                        label: Text('Chỉnh sửa',
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditInfoFreelancer(),
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  bio,
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.email, email),
                _buildInfoRow(Icons.phone, phoneNumber),
                _buildInfoRow(Icons.location_on, address),
                _buildInfoRow(Icons.business, city),
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

  Widget _buildSkillsCard() {
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
              children: [
                Text('Kỹ năng',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            _isEditing
                ? Column(
                    children: [
                      TextField(
                        controller: skillController,
                        decoration: InputDecoration(
                          hintText: 'Nhập kỹ năng mới',
                          hintStyle: TextStyle(color: Colors.red),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          if (skillController.text.isNotEmpty) {
                            // Add skill to Firebase Firestore
                            final userRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid);

                            await userRef.update({
                              'skills':
                                  FieldValue.arrayUnion([skillController.text]),
                            });

                            setState(() {
                              _skills.add(skillController.text);
                              skillController.clear();
                            });
                          }
                        },
                        child: Text(
                          'Thêm kỹ năng',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(67, 101, 222, 1)),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_skills as List<dynamic>)
                  .cast<String>()
                  .map((skill) => _buildSkillChip(skill))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Xóa kỹ năng'),
            content: Text(
              'Bạn có chắc chắn muốn xóa kỹ năng "$label"?',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Hủy',
                  style: TextStyle(
                      color: Color.fromRGBO(67, 101, 222, 1), fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Delete skill from Firebase Firestore
                  final userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid);

                  await userRef.update({
                    'skills': FieldValue.arrayRemove([label]),
                  });

                  setState(() {
                    _skills.remove(label);
                  });

                  Navigator.pop(context);
                },
                child: Text(
                  'Xóa',
                  style: TextStyle(
                      color: Color.fromRGBO(67, 101, 222, 1), fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
              children: [
                Text('Kinh nghiệm',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () {
                    setState(() {
                      _isExeriencing = !_isExeriencing;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            _isExeriencing
                ? Column(
                    children: [
                      TextField(
                        controller: jobNameController,
                        decoration: InputDecoration(
                          hintText: 'Tên công việc đã làm',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: jobDescriptionController,
                        decoration: InputDecoration(
                          hintText: 'Mô tả',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: periodController,
                        decoration: InputDecoration(
                          hintText: 'Thời gian làm việc (VD: 2018 - 2020)',
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 2),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          if (jobNameController.text.isNotEmpty &&
                              jobDescriptionController.text.isNotEmpty &&
                              periodController.text.isNotEmpty) {
                            // Add experience to Firebase Firestore
                            final userRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid);

                            await userRef.update({
                              'experiences': FieldValue.arrayUnion([
                                {
                                  'jobName': jobNameController.text,
                                  'jobDescription':
                                      jobDescriptionController.text,
                                  'period': periodController.text,
                                }
                              ]),
                            });

                            // Clear the form fields
                            jobNameController.clear();
                            jobDescriptionController.clear();
                            periodController.clear();
                          }
                        },
                        child: Center(
                          child: Text(
                            'Thêm kinh nghiệm',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(67, 101, 222, 1)),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
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
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // Spacer(),
            Expanded(
              flex: 0,
              child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text('Xóa kinh nghiệm'),
                        content: Text(
                          'Bạn có chắc chắn muốn xóa kinh nghiệm này?',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                  fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Delete experience from Firebase Firestore
                              final userRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid);

                              await userRef.update({
                                'experiences': FieldValue.arrayRemove(
                                    [experiences[index]]),
                              });

                              setState(() {
                                experiences.removeAt(index);
                              });

                              Navigator.pop(context);
                            },
                            child: Text(
                              'Xóa',
                              style: TextStyle(
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    Icons.delete_outline_outlined,
                    color: Colors.red,
                  )),
            ),
          ],
        ),
        SizedBox(height: 2),
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
          .where('customerID',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Center(child: Text("Hiện chưa có đánh giá"))
                ],
              ),
            ),
          );
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
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OtherUserProfilePage(userId: feedback['employerUID']),
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

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListCandidate() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Hiện bạn chưa có bài viết gì'),
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
}

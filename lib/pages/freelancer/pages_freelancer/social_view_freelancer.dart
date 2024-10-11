import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/job_list.dart';
import 'package:freelancer/components/user_post_compo.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/upload_jobs.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/upload_post.dart';
import 'package:freelancer/services/auth/auth_service.dart';

class SocialViewFreelancer extends StatefulWidget {
  const SocialViewFreelancer({super.key});

  @override
  _SocialViewFreelancerState createState() => _SocialViewFreelancerState();
}

class _SocialViewFreelancerState extends State<SocialViewFreelancer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  late Map<String, dynamic> userData;
  String userName = "";
  String email = "";
  String receiverID = "";
  String avatar = "";
  String message = "";
  String position = "";
  bool fillter = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
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
          position = doc['position'] ?? "";
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Implement search functionality here
    print(_searchController.text);
  }

  void postPost() async {
    if (_textController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userName = doc['name'] ?? "";
        final avatar = doc['avatar'] ?? "";

        FirebaseFirestore.instance.collection("posts").add({
          'uid': user.uid,
          'userName': userName,
          'avatar': avatar,
          'content': _textController.text,
          'timestamp': Timestamp.now(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void onSortSelected(String value) {
      switch (value) {
        case 'new_to_old':
          fillter = true;
          break;

        case 'old_to_new':
          fillter = false;
          break;
      }

      // Trigger a rebuild of the _buildPostListJob widget
      setState(() {});
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        centerTitle: true,
        title: Text(
          'Khám phá',
        ),
        elevation: 0,
        actions: [
          // PopupMenuButton<String>(
          //   onSelected: (value) => onSortSelected(value),
          //   itemBuilder: (context) => [
          //     PopupMenuItem<String>(
          //       value: 'new_to_old',
          //       child: Text('Mới đến cũ'),
          //     ),
          //     PopupMenuItem<String>(
          //       value: 'old_to_new',
          //       child: Text('Cũ đến mới'),
          //     ),
          //   ],
          // ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: InputDecoration(
          //       hintText: 'Tìm kiếm công việc, ứng viên, công ty...',
          //       prefixIcon: Icon(Icons.search),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(30),
          //         borderSide: BorderSide.none,
          //       ),
          //       filled: true,
          //       fillColor: Colors.white,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ], color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(avatar),
                      ),
                      SizedBox(width: 12),
                      _uploadNewPost(context),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Việc làm'),
              Tab(text: 'Ứng viên'),
              Tab(text: 'Chia sẻ'),
            ],
            labelColor: Color.fromRGBO(67, 101, 222, 1),
            labelStyle: TextStyle(
              fontSize: 16,
            ),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Color.fromRGBO(67, 101, 222, 1),
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostListJob(),
                _buildPostListCandidate(),
                _buildPostListShare()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _uploadNewPost(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            showDragHandle: true,
            context: context,
            builder: (context) {
              return Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          'Chọn thể loại bài viết bạn muốn đăng:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UploadJobs(gallery: false))),
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 25),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 187, 187, 187),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.work_outline),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Việc làm',
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          Text(
                                            "Đăng tin tuyển dụng cho công việc của bạn",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UploadPost(
                                            gallery: true,
                                            selectedRole: "Ứng viên",
                                          ))),
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 25),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 187, 187, 187),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_outline),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Giới thiệu Ứng viên',
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          Text(
                                            "Đăng hồ sơ của bạn",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UploadPost(
                                            gallery: true,
                                            selectedRole: "Chia sẻ",
                                          ))),
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 25),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 187, 187, 187),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.book_outlined),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Chia sẻ',
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          Text(
                                            "Đăng kiến thức, kinh nghiệm, trải nghiệm",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ));
            },
          );
        },
        child: Row(
          children: const [
            Text(
              "Bạn đang nghĩ gì",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListJob() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .orderBy("timestamp", descending: fillter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];
                  if (post["uid"] == user?.uid) {}
                  return JobList(
                    experience: post["experience"],
                    description: post["description"],
                    enroll_end_time: post["enroll_end_time"],
                    enroll_start_time: post["enroll_start_time"],
                    happeningTime: post["happening_time"],
                    location: post["location"],
                    requirement: post["requirement"],
                    salary: post["salary"],
                    skills: post["skills"],
                    title: post["title"],
                    category: post["category"],
                    uid: post["uid"],
                    timestamp: post["timestamp"],
                    jobID: post["jobID"],
                    enrolls: List<String>.from(
                      post["enrolls"] ?? [],
                    ),
                    accepted: List<String>.from(
                      post["accepted"] ?? [],
                    ),
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

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListCandidate() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('category', isEqualTo: 'Ứng viên')
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                return UserPostCompo(
                    content: post["content"],
                    uid: post["uid"],
                    image: post["image"],
                    timestamp: post["timestamp"],
                    postId: post.id,
                    likes: List<String>.from(
                      post["likes"] ?? [],
                    )
                    // Pass the post ID
                    );
              });
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error"),
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

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListShare() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('category', isEqualTo: 'Chia sẻ')
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                return UserPostCompo(
                  content: post["content"],
                  uid: post["uid"],
                  image: post["image"],
                  timestamp: post["timestamp"],
                  postId: post.id,
                  likes: List<String>.from(post["likes"] ?? []),
                  // Pass the post ID
                );
              });
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error"),
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
}

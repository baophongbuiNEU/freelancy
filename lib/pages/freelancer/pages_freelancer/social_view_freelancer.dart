import 'dart:async';
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
  bool jobFillter = true;
  bool candidateFillter = true;
  String candidateSort = "";

  bool shareFillter = true;

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
    _refreshFuture = _loadData();
  }

  // void changeFillter(bool newFillter) {
  //   fillter = newFillter;
  //   _filterController.add(fillter);
  // }

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

  late Future<void> _refreshFuture;

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 0)); // Simulating data load
  }

  void _refreshPage() {
    setState(() {
      _refreshFuture = _loadData(); // Set new future to refresh content
    });
  }

  @override
  Widget build(BuildContext context) {
    void sortJob(String value) {
      switch (value) {
        case 'new_to_old':
          jobFillter = true;

          _refreshPage();
          break;

        case 'old_to_new':
          jobFillter = false;
          _refreshPage();
          break;
      }
    }

    void sortCandidate(String value) {
      switch (value) {
        case 'new_to_old':
          candidateFillter = true;
          candidateSort = "";

          _refreshPage();
          break;

        case 'old_to_new':
          candidateFillter = false;
          candidateSort = "";

          _refreshPage();
          break;
        case 'Ứng viên':
          candidateFillter = true;
          candidateSort = "Chia sẻ";
          _refreshPage();
          break;

        case 'Chia sẻ':
          candidateFillter = true;
          candidateSort = "Ứng viên";
          _refreshPage();
          break;
      }
    }

    void sortShare(String value) {
      switch (value) {
        case 'new_to_old':
          shareFillter = true;

          _refreshPage();
          break;

        case 'old_to_new':
          shareFillter = false;
          _refreshPage();
          break;
      }
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
          if (MediaQuery.of(context).size.height < 700)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addNewJobOrPost(context),
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _refreshFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              if (MediaQuery.of(context).size.height > 700)
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
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
              if (MediaQuery.of(context).size.height > 700)
                SizedBox(
                  height: 15,
                ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Việc làm'),
                  Tab(text: 'Bài viết'),
                  // Tab(text: 'Chia sẻ'),
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
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sắp xếp theo",
                                style: TextStyle(
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                ),
                              ),
                              SizedBox(
                                width: 0,
                              ),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                icon: Icon(
                                  Icons.filter_list,
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                ),
                                onSelected: (value) => sortJob(value),
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'new_to_old',
                                    child: Text('Mới đến cũ'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'old_to_new',
                                    child: Text('Cũ đến mới'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildPostListJob()),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sắp xếp theo",
                                style: TextStyle(
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                ),
                              ),
                              SizedBox(
                                width: 0,
                              ),
                              PopupMenuButton<String>(
                                color: Colors.white,
                                icon: Icon(
                                  Icons.filter_list,
                                  color: Color.fromRGBO(67, 101, 222, 1),
                                ),
                                onSelected: (value) => sortCandidate(value),
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'new_to_old',
                                    child: Text('Mới đến cũ'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'old_to_new',
                                    child: Text('Cũ đến mới'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Ứng viên',
                                    child: Text('Tìm theo Ứng viên'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Chia sẻ',
                                    child: Text('Tìm theo Chia sẻ'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildPostListCandidate()),
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.only(right: 20),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           Text(
                    //             "Sắp xếp theo",
                    //             style: TextStyle(
                    //               color: Color.fromRGBO(67, 101, 222, 1),
                    //             ),
                    //           ),
                    //           SizedBox(
                    //             width: 0,
                    //           ),
                    //           PopupMenuButton<String>(
                    //             color: Colors.white,
                    //             icon: Icon(
                    //               Icons.filter_list,
                    //               color: Color.fromRGBO(67, 101, 222, 1),
                    //             ),
                    //             onSelected: (value) => sortShare(value),
                    //             itemBuilder: (context) => [
                    //               PopupMenuItem<String>(
                    //                 value: 'new_to_old',
                    //                 child: Text('Mới đến cũ'),
                    //               ),
                    //               PopupMenuItem<String>(
                    //                 value: 'old_to_new',
                    //                 child: Text('Cũ đến mới'),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Expanded(child: _buildPostListShare()),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListJob() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .where('category', isNotEqualTo: 'Done')
          .where('enroll_end_time', isGreaterThan: Timestamp.now())
          .orderBy("timestamp", descending: jobFillter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text('Hiện chưa có công việc nào'),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final post = docs[index];
                final jobID = post["jobID"];

                // Check if the job still exists
                if (jobID != null) {
                  return JobList(
                    key: ValueKey(jobID), // Add a unique key for each job item
                    jobID: jobID,
                  );
                } else {
                  return SizedBox.shrink(); // Placeholder for non-existent job
                }
              },
            ),
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
          ),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListCandidate() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('category', isNotEqualTo: candidateSort)
          .orderBy("timestamp", descending: candidateFillter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text('Hiện bạn chưa có bài viết gì'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final post = docs[index];
              final postId = post.id;

              // Check if post exists before rendering
              if (post.exists) {
                return UserPostCompo(
                  key: ValueKey(postId), // Unique key for each post
                  content: post["content"],
                  uid: post["uid"],
                  image: post["image"],
                  timestamp: post["timestamp"],
                  postId: postId,
                  likes: List<String>.from(post["likes"] ?? []),
                );
              } else {
                return SizedBox.shrink(); // Placeholder for non-existent post
              }
            },
          );
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
          ),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListShare() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('category', isEqualTo: 'Chia sẻ')
          .orderBy("timestamp", descending: shareFillter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text('Hiện bạn chưa có bài viết gì'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final post = docs[index];
              final postId = post.id;

              // Check if post exists before rendering
              if (post.exists) {
                return UserPostCompo(
                  key: ValueKey(postId), // Unique key for each post
                  content: post["content"],
                  uid: post["uid"],
                  image: post["image"],
                  timestamp: post["timestamp"],
                  postId: postId,
                  likes: List<String>.from(post["likes"] ?? []),
                );
              } else {
                return SizedBox.shrink(); // Placeholder for non-existent post
              }
            },
          );
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
          ),
        );
      },
    );
  }

  Expanded _uploadNewPost(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: GestureDetector(
        onTap: () {
          _addNewJobOrPost(context);
        },
        child: Row(
          children: const [
            Expanded(
              child: Text(
                "Đăng tải công việc và bài viết tại đây!",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
              ),
            ),
            // Spacer(),
            Expanded(
              flex: 0,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> _addNewJobOrPost(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 0,
                  child: ListTile(
                    title: Text(
                      'Chọn thể loại bạn muốn đăng:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UploadJobs()))
                              .then((_) {
                            _refreshPage();
                          });
                        },
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 0, child: Icon(Icons.work_outline)),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Việc làm',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Text(
                                        "Đăng tin tuyển dụng cho công việc của bạn",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15),
                                      )
                                    ],
                                  ),
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
                                    ))).then((_) {
                          _refreshPage();
                        }),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 0, child: Icon(Icons.person_outline)),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Giới thiệu Ứng viên',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Text(
                                        "Đăng hồ sơ của bạn",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
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
                                    ))).then((_) {
                          _refreshPage();
                        }),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 0, child: Icon(Icons.book_outlined)),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chia sẻ',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Text(
                                        "Đăng kiến thức, kinh nghiệm, trải nghiệm",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15),
                                      )
                                    ],
                                  ),
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
  }
}

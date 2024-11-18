import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/job_list.dart';
import 'package:freelancer/components/user_tile.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/chat_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';

class JobSearchPage extends StatefulWidget {
  const JobSearchPage({super.key});

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  List _nameResults = [];
  List _jobResults = [];
  List _nameList = [];
  List _jobList = [];
  List _originalJobList = []; // New list to store original jobs

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserStream();
    getJobStream();
    _searchController.addListener(_onSearchChanged);
    _refreshFuture = _loadData();
  }

  _onSearchChanged() {
    print(_searchController.text);
    searchUserList();
    searchJobList();
  }

  getUserStream() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .get();
    setState(() {
      _nameResults = data.docs;
    });
    searchUserList(); // Call search after fetching the users
  }

  getJobStream() async {
    var data = await FirebaseFirestore.instance
        .collection('jobs')
        .where("category", isNotEqualTo: "Done")
        .where('enroll_end_time', isGreaterThan: Timestamp.now())
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      _jobResults = data.docs;
      _originalJobList = List.from(_jobResults); // Store original jobs
    });
    searchJobList(); // Apply search filter after fetching the jobs
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getUserStream();
    getJobStream();
    super.didChangeDependencies();
  }

  searchUserList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var userSnapshot in _nameResults) {
        var name = userSnapshot['name'].toString().toLowerCase();
        var skills = List<String>.from(userSnapshot['skills']);
        var position = userSnapshot['position'].toString().toLowerCase();
        if (name.contains(_searchController.text.toLowerCase()) ||
            position.contains(_searchController.text.toLowerCase()) ||
            skills.any((skill) => skill
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))) {
          showResults.add(userSnapshot);
        }
      }
    } else {
      showResults = List.from(_nameResults);
      _refreshPage();
    }

    setState(() {
      _nameList = showResults;
    });
  }

  searchJobList() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var jobSnapshot in _originalJobList) {
        // Use the original job list for searching
        var title = jobSnapshot['title'].toString().toLowerCase();
        var category = jobSnapshot['category']
            .toString()
            .toLowerCase(); // Assuming category is a string field
        var location = jobSnapshot['location']
            .toString()
            .toLowerCase(); // Assuming category is a string field

        // Check if the search term matches the title or category
        if (title.contains(_searchController.text.toLowerCase()) ||
            category.contains(_searchController.text.toLowerCase()) ||
            location.contains(_searchController.text.toLowerCase())) {
          showResults.add(jobSnapshot);
        }
      }
    } else {
      showResults = List.from(_originalJobList);
    }

    setState(() {
      _jobList = showResults; // Set the job list to the filtered results
    });
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: "Tìm theo công việc hoặc tên Freelancer",
        ),
      ),
      body: FutureBuilder<void>(
        future: _refreshFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12.0, right: 12, left: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _jobList.isNotEmpty
                      ? Text(
                          "Công việc",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      : SizedBox.shrink(),
                  _jobList.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _jobList.length,
                          itemBuilder: (context, index) {
                            return JobList(
                              jobID: _jobList[index]['jobID'],
                            );
                          },
                        )
                      : SizedBox.shrink(),
                  _jobList.isNotEmpty
                      ? SizedBox(
                          height: 20,
                        )
                      : SizedBox.shrink(),
                  _nameList.isNotEmpty
                      ? Text(
                          "Freelancer",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      : SizedBox.shrink(),
                  _nameList.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _nameList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: UserTile(
                                  email: _nameList[index]["email"],
                                  avatar: _nameList[index]['avatar'],
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OtherUserProfilePage(
                                                            userId:
                                                                _nameList[index]
                                                                    ["uid"],
                                                          )));
                                            },
                                            receiverEmail: _nameList[index]
                                                ["name"],
                                            receiverID: _nameList[index]["uid"],
                                            avatar: _nameList[index]["avatar"],
                                          ),
                                        ));
                                  },
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherUserProfilePage(
                                                  userId: _nameList[index]
                                                      ["uid"],
                                                )));
                                  },
                                  userName: _nameList[index]["name"]),
                            );
                          },
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

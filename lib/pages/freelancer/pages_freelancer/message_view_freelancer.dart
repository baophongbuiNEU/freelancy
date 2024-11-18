import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer/components/user_tile.dart';
import 'package:freelancer/components/user_tile_message.dart';
import 'package:freelancer/pages/freelancer/auth_freelancer/login_or_register_freelancer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/chat_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:freelancer/services/chat/chat_service.dart';

import 'package:get_time_ago/get_time_ago.dart';

class MessageViewFreelancer extends StatefulWidget {
  const MessageViewFreelancer({super.key});

  @override
  State<MessageViewFreelancer> createState() => _MessageViewFreelancerState();
}

class _MessageViewFreelancerState extends State<MessageViewFreelancer>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
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

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void logout(BuildContext context) {
    final auth = AuthService();
    auth.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginOrRegisterFreelancer()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          centerTitle: true,
          title: Text(
            "Tin nhắn",
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => logout(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(
            //       left: 25, right: 25, bottom: 10, top: 10),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(30),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.3),
            //           spreadRadius: 2,
            //           blurRadius: 3,
            //           offset: Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: TextField(
            //       controller: _searchController,
            //       decoration: InputDecoration(
            //         hintStyle: TextStyle(
            //             color: Colors.grey, fontWeight: FontWeight.normal),
            //         hintText: 'Tìm kiếm người dùng...',
            //         prefixIcon: Icon(
            //           Icons.search,
            //           color: Color.fromRGBO(67, 101, 222, 1),
            //         ),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(30),
            //           borderSide: BorderSide.none,
            //         ),
            //         filled: true,
            //         fillColor: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Cuộc trò chuyện gần đây'),
                Tab(text: 'Tất cả người dùng'),
              ],
              labelColor: Color.fromRGBO(67, 101, 222, 1),
              labelStyle: TextStyle(
                fontSize: 16,
              ),
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Color.fromRGBO(67, 101, 222, 1),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserListChatted(),
                  _buildUserList(),
                ],
              ),
            ),
          ],
        ));
  }

  StreamBuilder<QuerySnapshot<Object?>> _buildUserListChatted() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getUserStreamChat(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading"));
        }

        final chatRooms = snapshot.data!.docs;

        if (chatRooms.isEmpty) {
          return Center(child: Text("Chưa có cuộc trò chuyện nào"));
        }

        List<String> otherUserIDs = chatRooms.map((doc) {
          List<String> userIDs = List<String>.from(doc['participantsList']);
          userIDs.remove(_authService.getCurrentUser()!.uid);
          return userIDs.first;
        }).toList();

        return ListView.builder(
          itemCount: otherUserIDs.length,
          itemBuilder: (context, index) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserIDs[index])
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return SizedBox.shrink();
                }

                Map<String, dynamic> userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(chatRooms[index].id)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, messageSnapshot) {
                    if (!messageSnapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    Map<String, dynamic> lastMessageData =
                        messageSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;

                    return _buildUserListItem(
                      context,
                      userData,
                      lastMessageData['message'],
                      lastMessageData['timestamp'],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamRecentAll(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading"));
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItemAll(
                    context,
                    userData,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(BuildContext context, Map<String, dynamic> userData,
      String lastMessage, Timestamp timestamp) {
    // display all users except current user
    if (userData['email'] != _authService.getCurrentUser()!.email) {
      DateTime sendTime = DateTime.parse(timestamp.toDate().toString());
      DateTime currentDate = DateTime.now();
      int daysSend = sendTime.difference(currentDate).inDays;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: UserTileMessage(
            sendTime: daysSend > 1
                ? sendTime.toString().substring(0, 10)
                : GetTimeAgo.parse(
                    DateTime.parse(timestamp.toDate().toString())),
            lastMessage: lastMessage.length > 15
                ? '${lastMessage.substring(0, 15)}...'
                : lastMessage,
            avatar: userData['avatar'],
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OtherUserProfilePage(
                                      userId: userData["uid"],
                                    )));
                      },
                      receiverEmail: userData["name"],
                      receiverID: userData["uid"],
                      avatar: userData["avatar"],
                    ),
                  ));
            },
            userName: userData["name"]),
      );
    } else {
      return Container();
    }
  }

  Widget _buildUserListItemAll(
      BuildContext context, Map<String, dynamic> userData) {
    // display all users except current user
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null && userData['email'] != currentUser.email) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: UserTile(
            email: userData["email"],
            avatar: userData['avatar'],
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OtherUserProfilePage(
                                      userId: userData["uid"],
                                    )));
                      },
                      receiverEmail: userData["name"],
                      receiverID: userData["uid"],
                      avatar: userData["avatar"],
                    ),
                  ));
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtherUserProfilePage(
                            userId: userData["uid"],
                          )));
            },
            userName: userData["name"]),
      );
    } else {
      return Container();
    }
  }
}

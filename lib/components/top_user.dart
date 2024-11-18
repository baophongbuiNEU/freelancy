
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/user_tile.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/chat_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:freelancer/services/chat/chat_service.dart';


class TopUser extends StatefulWidget {
  const TopUser({super.key});

  @override
  State<TopUser> createState() => _TopUserState();
}

class _TopUserState extends State<TopUser> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String userName = "";
  String email = "";
  String avatar = "";
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserList();
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamRecent(),
      builder: (context, snapshot) {
        // Error handling
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        // Return ListView
        return ListView.builder(
          shrinkWrap: true, // Makes ListView take up only needed space
          physics: ClampingScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> userData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildUserListItem(context, userData);
          },
        );
      },
    );
  }

  //build individual list tile for user
  Widget _buildUserListItem(
      BuildContext context, Map<String, dynamic> userData) {
    // display all users except current user
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null && userData['email'] != currentUser.email) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 17),
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

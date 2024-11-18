import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/image_viewer.dart';
import 'package:freelancer/components/like_button.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/user_profile_page.dart';

import 'package:get_time_ago/get_time_ago.dart';

class UserPostProfile extends StatefulWidget {
  const UserPostProfile(
      {super.key,
      required this.content,
      required this.uid,
      required this.timestamp,
      required this.postId,
      required this.image,
      required this.likes,
      this.video});

  final String content;
  final String uid;
  final String? image;
  final String? postId;
  final String? video;
  final Timestamp timestamp;
  final List<String> likes;

  @override
  State<UserPostProfile> createState() => _UserPostCompoState();
}

class _UserPostCompoState extends State<UserPostProfile> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;

  bool _isExpanded = false;
  final bool _showDeleteOption = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
    isLiked = widget.likes.contains(FirebaseAuth.instance.currentUser?.email);
  }

  void toogleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("posts").doc(widget.postId);
    if (isLiked) {
      postRef.update({
        'likes':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.email])
      });
    } else {
      postRef.update({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final double widthImage = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!.data();
          return _buildPost(
              context, auth, user!, snapshot.connectionState, widthImage);
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> _deletePost() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .delete();
  }

  Widget _buildPost(
      BuildContext context,
      FirebaseAuth auth,
      Map<String, dynamic> user,
      ConnectionState connectionState,
      double widthImage) {
    DateTime sendTime = DateTime.parse(widget.timestamp.toDate().toString());
    DateTime currentDate = DateTime.now();
    int daysSend = sendTime.difference(currentDate).inDays;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => auth.currentUser!.uid == widget.uid
                      ? UserProfilePage()
                      : OtherUserProfilePage(userId: widget.uid),
                )),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
              ),
              title: Text(
                user['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              subtitle: Text(
                daysSend > 1
                    ? sendTime.toString().substring(0, 10)
                    : GetTimeAgo.parse(
                        DateTime.parse(widget.timestamp.toDate().toString())),
              ),
              trailing: auth.currentUser!.uid == widget.uid
                  ? PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          // if (_showDeleteOption)
          //   Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         TextButton(
          //           onPressed: () async {
          //             await FirebaseFirestore.instance
          //                 .collection('posts')
          //                 .doc(widget.postId)
          //                 .delete();
          //           },
          //           child: Text(
          //             'Delete',
          //             style: TextStyle(color: Colors.red),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(widget.content)),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewer(image: widget.image),
                )),
            child: Center(
              child: Container(
                child: widget.image != ''
                    ? Image.network(
                        widget.image!,
                        fit: BoxFit.cover,
                        height: widthImage,
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    LikeButton(
                      isLiked: isLiked,
                      onTap: toogleLike,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(widget.likes.length.toString()),
                  ],
                ),
                // _buildInteractionButton(Icons.comment, "30"),
                // _buildInteractionButton(Icons.share, "10"),
              ],
            ),
          ),
          Divider(
            thickness: 7,
            color: Color.fromRGBO(250, 250, 250, 1),
          )
        ],
      ),
    );
  }

  // Widget _buildInteractionButton(IconData icon, String count) {
  //   return Row(
  //     children: [
  //       Icon(icon, size: 16, color: Colors.grey),
  //       SizedBox(width: 4),
  //       Text(count, style: TextStyle(color: Colors.grey)),
  //     ],
  //   );
  // }

  Widget _buildContent(
    String content,
  ) {
    const int maxCharacters = 400;
    if (content.length >= maxCharacters) {
      String reducedText = '${content.substring(0, maxCharacters)}...';
      return RichText(
        text: TextSpan(
          text: _isExpanded ? content : reducedText,
          style: TextStyle(fontSize: 17, color: Colors.black),
          children: [
            if (!_isExpanded)
              TextSpan(
                text: !_isExpanded ? ' Xem thêm' : " Thu gọn",
                style: TextStyle(fontSize: 17, color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
              ),
            if (_isExpanded)
              TextSpan(
                text: !_isExpanded ? ' Xem thêm' : " Thu gọn",
                style: TextStyle(fontSize: 17, color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
              ),
          ],
        ),
      );
    } else {
      return Text(
        content != "" ? content : "",
        style: TextStyle(fontSize: 17, color: Colors.black),
      );
    }
  }
}

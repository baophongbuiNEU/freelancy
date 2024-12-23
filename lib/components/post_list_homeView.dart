import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/user_post_compo.dart';

class PostListHomeview extends StatelessWidget {
  const PostListHomeview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPostListCandidate();
  }
}

StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildPostListCandidate() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection("posts")
        // .where('category', isEqualTo: 'Ứng viên')
        .orderBy("timestamp", descending: true)
        .limit(2)
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
          shrinkWrap: true, // Makes ListView take up only needed space
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

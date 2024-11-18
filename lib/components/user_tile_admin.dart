
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/user_profile_page.dart';


class UserTileAdmin extends StatelessWidget {
  final String userID; // Only userID is required now
  final void Function()? onPressed;

  const UserTileAdmin({
    super.key,
    required this.userID,
    required this.onPressed,
  });

  Future<Map<String, dynamic>> _getUserData(String userID) async {
    // Fetch user data from Firestore
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();
    return userDoc.exists
        ? userDoc.data()!
        : {}; // Return user data or empty map if not found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(userID), // Fetch data asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading state
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error state
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('User not found')); // No user found
        }

        var userData = snapshot.data!;
        var userName = userData['name'] ?? 'Unknown';
        var avatar = userData['avatar'] ?? ''; // Default to empty if no avatar
        var email = userData['email'] ?? 'No email provided';

        return GestureDetector(
          onTap: () {
            userID == FirebaseAuth.instance.currentUser!.uid
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(),
                    ))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OtherUserProfilePage(userId: userID),
                    ));
          },
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircleAvatar(
                    backgroundImage:
                        avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar.isEmpty
                        ? Icon(Icons.person, size: 30)
                        : null, // Default to a person icon if no avatar
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

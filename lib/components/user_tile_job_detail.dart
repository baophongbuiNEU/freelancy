import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/confirmation_page_employer.dart';

class UserTileJobDetail extends StatefulWidget {
  final String userName;
  final String avatar;
  final void Function()? onTap;
  final String email;
  final String? jobID;
  final String uid;
  final bool isAccepted;
  final List<String> accepts;

  const UserTileJobDetail(
      {super.key,
      required this.onTap,
      required this.userName,
      required this.avatar,
      required this.email,
      required this.jobID,
      required this.uid,
      required this.isAccepted,
      required this.accepts});

  @override
  State<UserTileJobDetail> createState() => _UserTileJobDetailState();
}

class _UserTileJobDetailState extends State<UserTileJobDetail> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;

  bool isAccepted = false;
  bool isLoading = false;
  late String text;
  String accepted = "Đã chấp nhận";
  String rejected = "Chấp nhận";

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
    isAccepted =
        widget.accepts.contains(FirebaseAuth.instance.currentUser?.uid);
    print(isAccepted);
    isAccepted == false ? text = rejected : text = accepted;
  }

  void toggleAccept() async {
    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await Future.delayed(Duration(seconds: 2));

    try {
      // Fetch job details
      DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .doc(widget.jobID)
          .get();

      if (jobSnapshot.exists) {
        Map<String, dynamic> jobDetails =
            jobSnapshot.data() as Map<String, dynamic>;

        isAccepted = jobDetails['accepted'].contains(widget.uid);

        // Update or remove uid from Firebase
        DocumentReference postRef =
            FirebaseFirestore.instance.collection("jobs").doc(widget.jobID);

        if (isAccepted) {
          postRef.update({
            'accepted': FieldValue.arrayRemove([widget.uid]),
            'accepted_timestamps': FieldValue.arrayRemove(
                jobDetails['accepted_timestamps']
                    .where((timestamp) => timestamp['uid'] == widget.uid)
                    .toList()),
          });
        } else {
          postRef.update({
            'accepted': FieldValue.arrayUnion([widget.uid]),
            'accepted_timestamps': FieldValue.arrayUnion([
              {
                'uid': widget.uid,
                'timestamp': Timestamp.now(),
              }
            ]),
          });
          text = rejected;
        }
      }

      setState(() {
        isLoading = false;

        Navigator.pop(context);
        isAccepted = !isAccepted;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationPageEmployer(
                  jobID: widget.jobID, uid: widget.uid),
            ));
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> toggleAccept() async {
  //   // Show loading indicator (optional)
  //   // showDialog(
  //   //   context: context,
  //   //   barrierDismissible: false, // Prevent user from closing the dialog
  //   //   builder: (context) => Center(child: CircularProgressIndicator()),
  //   // );
  //   isAccepted = widget.isAccepted;
  //   try {
  //     // Fetch job details
  //     DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance
  //         .collection("jobs")
  //         .doc(widget.jobID)
  //         .get();

  //     if (jobSnapshot.exists) {
  //       Map<String, dynamic> jobDetails =
  //           jobSnapshot.data() as Map<String, dynamic>;

  //       isAccepted = jobDetails['accepted'].contains(widget.uid);

  //       // Update or remove uid from Firebase
  //       DocumentReference postRef =
  //           FirebaseFirestore.instance.collection("jobs").doc(widget.jobID);

  //       if (isAccepted) {
  //         await postRef.update({
  //           'accepted': FieldValue.arrayRemove([widget.uid]),
  //           'accepted_timestamps': FieldValue.arrayRemove(
  //               jobDetails['accepted_timestamps']
  //                   .where((timestamp) => timestamp['uid'] == widget.uid)
  //                   .toList()),
  //         });
  //         print(isAccepted);
  //       } else {
  //         await postRef.update({
  //           'accepted': FieldValue.arrayUnion([widget.uid]),
  //           'accepted_timestamps': FieldValue.arrayUnion([
  //             {
  //               'uid': widget.uid,
  //               'timestamp': Timestamp.now(),
  //             }
  //           ]),
  //         });
  //         print(isAccepted);
  //       }

  //       // Update local state (if needed) outside the widget tree
  //       if (mounted) {
  //         // Check if widget is still in the tree
  //         // Update your widget's state variable (isAccepted) here
  //       }
  //     }
  //   } catch (e) {
  //     // Handle error
  //   } finally {
  //     Navigator.pop(context); // Dismiss the loading indicator
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border:
              Border.all(color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.avatar,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: toggleAccept,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color.fromRGBO(67, 101, 222, 1),
                ),
                child: Text(
                  // isAccepted ? "Đã được nhận" : "Chấp nhận",
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/confirmation_page_employer.dart';

class UserTileJobConfirm extends StatefulWidget {
  final String userName;
  final String avatar;
  final void Function()? onTap;
  final String email;
  final String? jobID;
  final String uid;
  final bool isAccepted;
  final List<String> accepts;

  const UserTileJobConfirm(
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
  State<UserTileJobConfirm> createState() => _UserTileJobConfirmState();
}

class _UserTileJobConfirmState extends State<UserTileJobConfirm> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;

  bool isAccepted = false;
  bool isLoading = false;
  late String text;
  String accepted = "Đã chấp nhận";
  String rejected = "Chấp nhận";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 1.5),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 0,
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.avatar,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            // Spacer(),
            Expanded(
              flex: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmationPageEmployer(
                          jobID: widget.jobID, uid: widget.uid),
                    )),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromRGBO(67, 101, 222, 1),
                  ),
                  child: Text(
                    "Xem chi tiết",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

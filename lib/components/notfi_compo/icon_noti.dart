import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/notification_page.dart';

class IconNoti extends StatefulWidget {
  const IconNoti({super.key});

  @override
  State<IconNoti> createState() => _IconNotiState();
}

class _IconNotiState extends State<IconNoti> {
  final ValueNotifier<int> _unreadNotificationCount = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: 'enroll_noti')
          .where('employerUID',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Icon(
            Icons.notifications_none_outlined,
            size: 35,
            color: Color.fromRGBO(67, 101, 222, 1),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(
            Icons.notifications_none_outlined,
            size: 35,
            color: Color.fromRGBO(67, 101, 222, 1),
          );
        }
        int unreadCountEnroll =
            snapshot.data!.docs.where((doc) => doc['clicked'] == false).length;
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('type', isEqualTo: 'result_noti')
              .where('candidateID',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Icon(
                Icons.notifications_none_outlined,
                size: 35,
                color: Color.fromRGBO(67, 101, 222, 1),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Icon(
                Icons.notifications_none_outlined,
                size: 35,
                color: Color.fromRGBO(67, 101, 222, 1),
              );
            }
            int unreadCountResult = snapshot.data!.docs
                .where((doc) => doc['clicked'] == false)
                .length;
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('type', isEqualTo: 'finance_noti')
                  .where('candidateID',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                int unreadCountFinance = snapshot.data!.docs
                    .where((doc) => doc['clicked'] == false)
                    .length;
                _unreadNotificationCount.value =
                    unreadCountEnroll + unreadCountResult + unreadCountFinance;

                return Stack(children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(),
                            ));
                      },
                      icon: _unreadNotificationCount.value > 0
                          ? Icon(
                              Icons.notifications,
                              size: 35,
                              color: Color.fromRGBO(67, 101, 222, 1),
                            )
                          : Icon(
                              Icons.notifications_none_outlined,
                              size: 35,
                              color: Color.fromRGBO(67, 101, 222, 1),
                            )),
                  if (_unreadNotificationCount.value > 0)
                    Positioned(
                      top: 2,
                      right: 3,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _unreadNotificationCount.value.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ]);
              },
            );
          },
        );
      },
    );
  }
}

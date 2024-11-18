import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/notfi_compo/decrease_finance_noti.dart';

class TotalExpense extends StatefulWidget {
  const TotalExpense({super.key});

  @override
  State<TotalExpense> createState() => _TotalExpenseState();
}

class _TotalExpenseState extends State<TotalExpense> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text("Tổng chi tiêu"),
        centerTitle: true,
      ),
      body: _buildFinanceEnroll(),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildFinanceEnroll() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: "finance_noti")
          .where("employerUID",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];

                  return DecreaseFinanceNoti(
                    jobID: post["jobID"],
                    uid: post["candidateID"],
                    clicked: post["clicked"],
                    postID: post.id,
                    salarys: post['salary'],
                  );
                }),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return Center(
          child: Text("Hiện chưa có giao dịch nào"),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/other_user_profile_page.dart';
import 'package:intl/intl.dart';

class FeedbackViewer extends StatelessWidget {
  const FeedbackViewer(
      {super.key, required this.employerID, required this.jobID});
  final String jobID;
  final String employerID;

  @override
  Widget build(BuildContext context) {
    return _buildFeedbackForm();
  }

  Widget _buildFeedbackForm() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedbacks')
          .where('jobID', isEqualTo: jobID)
          .where('customerID',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final feedbacks = snapshot.data!.docs;

        if (feedbacks.isEmpty) {
          return Text('No feedback available');
        }

        return SingleChildScrollView(
          child: Column(
            children: feedbacks
                .map((feedback) => _buildFeedbackItem(feedback))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackItem(QueryDocumentSnapshot<Object?> feedback) {
    final employerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(feedback['employerUID']);

    return StreamBuilder<DocumentSnapshot>(
      stream: employerRef.snapshots(),
      builder: (context, employerSnapshot) {
        if (employerSnapshot.hasError) {
          return Text('Error fetching employer data');
        }

        if (!employerSnapshot.hasData) {
          return Text('Loading employer data');
        }

        final employer = employerSnapshot.data!;
        final employerName = employer['name'] ?? '';
        final employerAvatar = employer['avatar'] ?? '';

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OtherUserProfilePage(userId: feedback['employerUID']),
                    )),
                child: Row(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(employerAvatar),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employerName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(DateFormat('dd/MM/yyyy')
                            .format(feedback['timestamp'].toDate())),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Text(feedback['rating'].toString())
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 7),
              Text(
                feedback['feedback'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),

              // Divider(
              //   color: Colors.grey,
              //   thickness: 0.5,
              // ),
            ],
          ),
        );
      },
    );
  }
}

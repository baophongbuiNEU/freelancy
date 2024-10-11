import 'package:cloud_firestore/cloud_firestore.dart';

class JobsListModel {
  final String title;
  final String description;
  final Timestamp happeningDate;
  final Timestamp enroll_start_time;
  final Timestamp enroll_end_time;
  final String jobID;
  final String location;
  final String skills;
  final String salary;
  final String requirement;
  final String category;
  final Timestamp timestamp;

  final String experienceLevel;

  JobsListModel({
    required this.description,
    required this.title,
    required this.category,
    required this.happeningDate,
    required this.enroll_start_time,
    required this.enroll_end_time,
    required this.jobID,
    required this.location,
    required this.skills,
    required this.timestamp,
    required this.salary,
    required this.requirement,
    required this.experienceLevel,
  });
}

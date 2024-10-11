import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final List<String> participantsList;

  Message({
    required this.message,
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.timestamp,
    required this.participantsList,
  });

  factory Message.fromMap(Map map) {
    return Message(
      timestamp: map['timestamp'],
      senderID: map['senderID'],
      receiverID: map['receiverID'],
      participantsList: map['participantsList'],
      senderEmail: map['senderEmail'],
      message: map['message'],
    );
  }

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'participantsList': participantsList,
    };
  }
}

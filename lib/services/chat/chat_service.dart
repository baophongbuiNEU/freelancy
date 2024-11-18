import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelancer/models/message.dart';

class ChatService {
  // get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Stream<QuerySnapshot> getUserStreamChat() {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('participantsList', arrayContains: _auth.currentUser!.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessageOld(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    List<String> participantsList = [currentUserID, receiverID];
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      participantsList: participantsList,
    );

    participantsList.sort();
    String chatRoomID = participantsList.join('_');

    await _firestore.collection("chat_rooms").doc(chatRoomID).set({
      "participantsList": participantsList,
      "lastMessage": message, // Ensure this is a String
      "lastMessageTimestamp": timestamp,
    }, SetOptions(merge: true));

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    //construct a chatroom ID for the two users
    List<String> participantsList = [userID, otherUserID];
    participantsList.sort();
    String chatRoomID = participantsList.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> getUserStreamWithChats(
      String currentUserId) {
    // Stream to get chat IDs where current user is involved
    final chatListStream = _firestore
        .collection('chat_rooms')
        .where('participantsList', arrayContains: currentUserId)
        .snapshots();

    return chatListStream.asyncMap((chatSnapshot) async {
      // Extract chat IDs from the snapshot
      final List<String> chatIds =
          chatSnapshot.docs.map((doc) => doc.id).toList();

      // Stream to get users based on chat IDs (excluding current user)
      final userStream = _firestore
          .collection('users')
          .where('uid', whereIn: chatIds)
          .where('uid', isNotEqualTo: currentUserId)
          .snapshots();

      final userSnapshot =
          await userStream.first; // Wait for the first snapshot

      // Convert user documents to a list of maps
      return userSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStreamRecentAll() {
    return _firestore
        .collection("users")
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Stream<QuerySnapshot> getUserStreamRecent() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: false) // Sort by creation date
        .limit(3) // Limit to 3 documents
        .snapshots();
  }

  // Future<void> sendMessage(
  //     String senderID, String receiverID, String message) async {
  //   final ids = [senderID, receiverID];
  //   ids.sort();
  //   final id = ids.join('');
  //   await FirebaseFirestore.instance
  //       .collection('chat_rooms')
  //       .doc(id)
  //       .collection('messages')
  //       .doc()
  //       .set({
  //     'senderID': senderID,
  //     'message': message,
  //     'timestamp': Timestamp.now(),
  //   });
  // }

  Future<Message?> getRecentMessage(String user1, String user2) async {
    final chats = await getChats(user1, user2);
    chats.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return chats.firstOrNull;
  }

  Future<List<Message>> getChats(String user1, String user2) async {
    final ids = [user1, user2];
    ids.sort();
    final id = ids.join('');
    final messages = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(id)
        .collection('messages')
        .get();

    final result = <Message>[];
    for (var doc in messages.docs) {
      final data = doc.data();
      result.add(
        Message(
          message: data['message'],
          senderID: data['senderID'],
          senderEmail: data['senderEmail'],
          receiverID: data['receiverID'],
          timestamp: data['timestamp'],
          participantsList: data['participantsList'],
        ),
      );
    }
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:freelancer/components/user_tile.dart';
// import 'package:freelancer/components/user_tile_admin.dart';

// class AdminPage extends StatefulWidget {
//   const AdminPage({super.key});

//   @override
//   _AdminPageState createState() => _AdminPageState();
// }

// class _AdminPageState extends State<AdminPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Function to delete a user by user ID

//   Future<void> deleteUserWithReferences(String userID) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     WriteBatch batch = firestore.batch();

//     try {
//       // 1. Delete the user document from the 'users' collection
//       DocumentReference userDocRef = firestore.collection('users').doc(userID);
//       batch.delete(userDocRef);

//       // 2. Delete references in other collections where 'userID' is a field
//       // Example: Deleting user from 'jobs' collection where 'userID' matches
//       QuerySnapshot jobSnapshot = await firestore
//           .collection('jobs')
//           .where('uid', isEqualTo: userID)
//           .get();

//       for (var jobDoc in jobSnapshot.docs) {
//         batch.delete(jobDoc.reference);
//       }

//       // Example: Delete user from 'activities' collection where 'userID' matches
//       QuerySnapshot chatRoomSnapshot = await firestore
//           .collection('chat_rooms')
//           .where('participantsList', arrayContains: userID)
//           .get();

//       for (var chatRoomDoc in chatRoomSnapshot.docs) {
//         batch.delete(chatRoomDoc.reference);
//       }

//       // Add other collections as necessary by following the same pattern

//       // 3. Commit the batch operation
//       await batch.commit();
//       print("User and all references deleted successfully.");
//     } catch (e) {
//       print("Error deleting user and references: $e");
//       throw Exception("Failed to delete user and references.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Page - Manage Users'),
//       ),
//       body: StreamBuilder(
//         stream: _firestore.collection('users').orderBy('name').snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No users found'));
//           }

//           // Display a list of users
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var userDoc = snapshot.data!.docs[index];
//               var userId = userDoc.id;
//               var userName = userDoc['name'] ?? 'No Name';

//               return UserTileAdmin(
//                   userID: userId,
//                   onPressed: () => _confirmDelete(userId, userName));
//             },
//           );
//         },
//       ),
//     );
//   }

//   // Confirm delete dialog
//   void _confirmDelete(String userId, String userName) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete User'),
//         content: Text('Are you sure you want to delete $userName?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//               deleteUserWithReferences(userId); // Delete the user
//             },
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }

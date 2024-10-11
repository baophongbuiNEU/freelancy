import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(
      String userId, String childName, Uint8List file) async {
    Reference ref = _storage.ref().child('profileImage/$userId/$childName');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required String userId, // Add the user's ID as a required parameter

    required String name,
    required String bio,
    required String phoneNumber,
    required String address,
    required String city,
    required Uint8List file,
    required String position,
  }) async {
    String resp = " Some Error Occurred";
    try {
      if (name.isNotEmpty ||
          bio.isNotEmpty ||
          phoneNumber.isNotEmpty ||
          address.isNotEmpty ||
          city.isNotEmpty ||
          position.isNotEmpty) {
        String imageUrl =
            await uploadImageToStorage(userId, 'profileImage', file);
        await _firestore.collection('users').doc(userId).update({
          'name': name,
          'bio': bio,
          'avatar': imageUrl,
          'phoneNumber': phoneNumber,
          'address': address,
          'city': city,
          'position': position,
        });

        resp = 'success';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }

  Future<String> saveDataWithoutAvatar({
    required String userId, // Add the user's ID as a required parameter
    required String name,
    required String bio,
    required String phoneNumber,
    required String address,
    required String city,
    required String position,
  }) async {
    String resp = " Some Error Occurred";
    try {
      if (name.isNotEmpty ||
          bio.isNotEmpty ||
          phoneNumber.isNotEmpty ||
          address.isNotEmpty ||
          city.isNotEmpty ||
          position.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'name': name,
          'bio': bio,
          'phoneNumber': phoneNumber,
          'address': address,
          'city': city,
          'position': position,
        });

        resp = 'success';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}

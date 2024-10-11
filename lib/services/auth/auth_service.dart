import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Google Sign in
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOutWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signOut();
    if (gUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  //get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? getCurrentUserID() {
    return _auth.currentUser?.uid;
  }

  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _firestore.collection("users").doc(userCredential.user!.uid).set({
      //   'uid': userCredential.user!.uid,
      //   'email': userCredential.user!.email,
      // });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(
      String email,
      String password,
      String role,
      String name,
      String avatar,
      String bio,
      String address,
      Timestamp createdAt,
      String city,
      String position,
      String phoneNumber) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((UserCredential value) async {
        postDetailsToFirestore(
          value.user!.uid,
          email,
          role,
          name,
          password,
          avatar,
          bio,
          address,
          createdAt,
          city,
          position,
          phoneNumber,
        );
        return value;
      });

      // _firestore.collection("users").doc(userCredential.user!.uid).set({
      //   'uid': userCredential.user!.uid,
      //   'email': userCredential.user!.email,
      // });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  void postDetailsToFirestore(
    String uid,
    String email,
    String role,
    String name,
    String password,
    String avatar,
    String bio,
    String address,
    Timestamp createdAt,
    String city,
    String position,
    String phoneNumber,
  ) {
    _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'name': name,
      'password': password,
      'createdAt': Timestamp.now(),
      'avatar': avatar,
      'bio': bio,
      'address': address,
      'city': city,
      'position': position,
      'phoneNumber': phoneNumber,
      'uid': uid,
    });
  }
  //errors
}

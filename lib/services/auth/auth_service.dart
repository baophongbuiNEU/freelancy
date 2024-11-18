import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Google Sign in
  // signInWithGoogle() async {
  //   final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

  //   final GoogleSignInAuthentication gAuth = await gUser!.authentication;

  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: gAuth.accessToken,
  //     idToken: gAuth.idToken,
  //   );
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Now you can post details to Firestore, similar to the sign-up process
      // Post user details to Firestore
      postDetailsToFirestore(
        userCredential.user!.uid,
        gUser.email, // Use the Google email
        "freelancer", // Assuming a default role, modify as needed
        gUser.displayName ??
            'No Name', // Google user display name, if available
        "",
        "",
        "",
        "",
        Timestamp.now(),
        "",
        "",
        "",
        [],
        [],
      );

      // Post finance details to Firestore
      postFinanceToFirestore(
        userCredential.user!.uid,
        gUser.displayName ?? 'No Name', // Use the Google user name
        0,
        0,
        0,
        0,
      );

      return userCredential;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
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
    String phoneNumber,
    num sumIncome,
    num numProjects,
    num numExpenses,
    num numProfits,
    List<String> skills,
    List<String> experiences,
  ) async {
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
          skills,
          experiences,
        );
        return value;
      }).then((UserCredential value2) async {
        postFinanceToFirestore(
          value2.user!.uid,
          name,
          sumIncome,
          numProjects,
          numExpenses,
          numProfits,
        );
        return value2;
      });

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
    List<String> skills,
    List<String> experiences,
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
      'skills': skills,
      'experiences': experiences,
    });
  }

  void postFinanceToFirestore(
    String uid,
    String name,
    num sumIncome,
    num numProjects,
    num numExpenses,
    num numProfits,
  ) {
    _firestore.collection('finance').doc(uid).set({
      'uid': uid,
      'name': name,
      'income': sumIncome,
      'numProjects': numProjects,
      'numExpenses': numExpenses,
      'numProfits': numProfits,
    });
  }
  //errors
}

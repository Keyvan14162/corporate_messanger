import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Streamler {
  getAllUsers() {
    var userStream = FirebaseFirestore.instance.collection("users").snapshots();

    return userStream;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getFriends() {
    var friends = FirebaseFirestore.instance
        .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
        .snapshots();

    return friends;
  }
}

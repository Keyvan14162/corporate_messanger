import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class LoginControl extends StatefulWidget {
  const LoginControl({Key? key}) : super(key: key);

  @override
  State<LoginControl> createState() => _LoginControlState();
}

class _LoginControlState extends State<LoginControl> {
  // auth initialize
  late FirebaseAuth auth;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    girisYonlendir();
  }

  void girisYonlendir() {
    auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        print("giris ekrani");
        Navigator.of(context).pushNamed(Constants.LOGIN_SCREEN_PATH);
      } else {
        // /anaSayfa
        Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH,
            arguments: auth.currentUser!.uid);
        // print("User signed in ${user.email} - ${user.emailVerified}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Bilgiler Kontrol Ediliyor..."),
      ),
    );
  }
}

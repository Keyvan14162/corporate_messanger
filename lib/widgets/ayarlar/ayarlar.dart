import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/ayarlar_menu_items.dart';

import 'profileImg.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({Key? key}) : super(key: key);

  @override
  State<Ayarlar> createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  late FirebaseAuth auth;
  final double coverImgHeight = 200;
  final double profileHeight = 144;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverImgHeight - profileHeight / 2;
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamed("/girisEkrani");
        return Future.value(false);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                ProfileImg(
                  coverImgHeight: coverImgHeight,
                  top: top,
                  profileHeight: profileHeight,
                  userId: auth.currentUser!.uid,
                  userName: getUserName(),
                ),
                const SizedBox(height: 100),
                Text("Name : ${auth.currentUser!.uid}"),
                Text("Email : ${auth.currentUser!.email}"),
                Text("Mail verified : ${auth.currentUser!.emailVerified}"),
                Text("Telefon : ${auth.currentUser!.phoneNumber}"),
                const AyarlarMenuItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getUserName() async {
    // one time read
    var name = (await FirebaseFirestore.instance
            .doc("users/${auth.currentUser!.uid}")
            .get())
        .data()!["name"];

    return name;
  }
}

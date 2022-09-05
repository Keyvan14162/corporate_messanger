import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GirisKontrol extends StatefulWidget {
  const GirisKontrol({Key? key}) : super(key: key);

  @override
  State<GirisKontrol> createState() => _GirisKontrolState();
}

class _GirisKontrolState extends State<GirisKontrol> {
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
        Navigator.of(context).pushNamed("/girisEkrani");
      } else {
        // /anaSayfa
        Navigator.of(context)
            .pushNamed("/anaSayfa", arguments: auth.currentUser!.uid);
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

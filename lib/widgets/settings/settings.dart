import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/widgets/settings/settings_menu_items.dart';
import 'profile_img.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
        Navigator.of(context).pushNamed(Constants.LOGIN_SCREEN_PATH);
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
                  userName: getUserName(auth.currentUser!.uid),
                ),
                const SizedBox(height: 100),
                Text("Name : ${auth.currentUser!.uid}"),
                Text("Email : ${auth.currentUser!.email}"),
                Text("Mail verified : ${auth.currentUser!.emailVerified}"),
                Text("Telefon : ${auth.currentUser!.phoneNumber}"),
                const SettingsMenuItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

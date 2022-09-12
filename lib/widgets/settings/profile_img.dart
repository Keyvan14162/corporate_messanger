import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class ProfileImg extends StatefulWidget {
  const ProfileImg({
    Key? key,
    required this.coverImgHeight,
    required this.top,
    required this.profileHeight,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  final double coverImgHeight;
  final double top;
  final double profileHeight;
  final String userId;
  final Future<String> userName;

  @override
  State<ProfileImg> createState() => _ProfileImgState();
}

class _ProfileImgState extends State<ProfileImg> {
  StreamSubscription? userSubscribe;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // cover img
        FutureBuilder<String>(
          future: getDownloadUrl(widget.userId, "coverImg"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GestureDetector(
                onTap: () {
                  changeCoverImg(widget.userId);
                  Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH);
                },
                child: Container(
                  color: Colors.grey,
                  child: Image.network(
                    snapshot.data.toString(),
                    width: double.infinity,
                    height: widget.coverImgHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else {
              return const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        // profile img
        FutureBuilder<String>(
          future: getDownloadUrl(widget.userId, "profileImg"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Positioned(
                top: widget.top,
                left: 0,
                right: MediaQuery.of(context).size.width / 2,
                child: GestureDetector(
                  onTap: () {
                    changeProfileImg(context, widget.userId);
                  },
                  child: CircleAvatar(
                    radius: widget.profileHeight / 2 + 10,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: widget.profileHeight / 2,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: NetworkImage(snapshot.data.toString()),
                    ),
                  ),
                ),
              );
            } else {
              return Positioned(
                top: widget.top,
                right: MediaQuery.of(context).size.width / 3,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        // name
        FutureBuilder(
          future: widget.userName,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Positioned(
                top: widget.coverImgHeight + 10,
                right: 10,
                child: Text(
                  snapshot.data.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 30),
                ),
              );
            } else {
              return Positioned(
                top: widget.coverImgHeight + 10,
                right: 10,
                child: const Text(
                  "",
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

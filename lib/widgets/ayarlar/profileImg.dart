import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
        FutureBuilder<String>(
          future: getDownloadUrl(widget.userId, "coverImg"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GestureDetector(
                onTap: changeCoverImg,
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
        FutureBuilder<String>(
          future: getDownloadUrl(widget.userId, "profileImg"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Positioned(
                top: widget.top,
                left: 0,
                // neden 3 bilmiyom
                right: MediaQuery.of(context).size.width / 2,
                child: GestureDetector(
                  onTap: changeProfileImg,
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

  changeProfileImg() async {
    // firestore'a id ile isimlendirip resmi atsın
    // firebase de userin profileImg download urlsini degistrisin
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Uyarı"),
          content: const Text("Profil resminiz değiştirmek ister misiniz ?"),
          actions: [
            TextButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                XFile? file =
                    await picker.pickImage(source: ImageSource.camera);

                var profileRef = FirebaseStorage.instance
                    .ref("users/profilePics/${widget.userId}");

                var task = profileRef.putFile(File(file!.path));

                task.whenComplete(() async {
                  var url = await profileRef.getDownloadURL();
                  // dbye url yi yazdircaz

                  FirebaseFirestore.instance
                      .doc("users/${widget.userId}")
                      .update({"profileImg": url.toString()});
                });
              },
              child: const Text("Evet"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hayır"),
            ),
          ],
        );
      },
    );
  }

  changeCoverImg() async {
    // firestore'a id ile isimlendirip resmi atsın
    // firebase de userin profileImg download urlsini degistrisin
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.camera);

    var profileRef =
        FirebaseStorage.instance.ref("users/coverPics/${widget.userId}");

    var task = profileRef.putFile(File(file!.path));

    task.whenComplete(() async {
      var url = await profileRef.getDownloadURL();
      // dbye url yi yazdircaz

      FirebaseFirestore.instance
          .doc("users/${widget.userId}")
          .update({"coverImg": url.toString()});
    });
  }

  // user fieldalrinda kayitli olan coverImg ve profileImg aliyor
  Future<String> getDownloadUrl(String userId, String img) async {
    // one time read
    var url = (await FirebaseFirestore.instance.doc("users/${userId}").get())
        .data()![img];

    return url;
  }
}

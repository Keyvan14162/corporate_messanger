import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TumKullanicilar extends StatefulWidget {
  const TumKullanicilar({Key? key}) : super(key: key);

  @override
  State<TumKullanicilar> createState() => _TumKullanicilarState();
}

class _TumKullanicilarState extends State<TumKullanicilar> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Kullanıcı Ara',
          style: TextStyle(color: ThemeData().primaryColor),
        ),
        backgroundColor: Colors.white,
        actions: [
          // Navigate to the Search Screen

          IconButton(
            onPressed: () => Navigator.of(context).pushNamed("/searchPage"),
            icon: Icon(
              Icons.search,
              color: ThemeData().primaryColor,
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: getAllUserss(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              key: const PageStorageKey<String>("page"),
              padding: const EdgeInsets.all(10.0),
              itemCount: (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                  .docs
                  .length,
              itemBuilder: (context, index) {
                var name =
                    (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                        .docs[index]
                        .data()["name"]
                        .toString();
                var userId =
                    (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                        .docs[index]
                        .id
                        .toString();

                var profileImgUrl =
                    (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                        .docs[index]
                        .data()["profileImg"]
                        .toString();

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/personalChat",
                        arguments: [
                          FirebaseAuth.instance.currentUser!.uid,
                          userId
                        ]);
                  },
                  child: FirebaseAuth.instance.currentUser!.uid != userId
                      ? Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ListTile(
                              leading: profileImgUrl.contains("null")
                                  ? const Icon(Icons.person)
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(profileImgUrl),
                                    ),
                              title: Text(
                                name,
                              ),
                              subtitle: Text(userId),
                            ),
                          ),
                        )
                      : const SizedBox(),
                );
              },
            );
          }
        },
      ),
    );
  }

  getAllUserss() {
    var userStream = firestore.collection("users").snapshots();
    return userStream;
  }
}

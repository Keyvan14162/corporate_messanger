import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String dropdownValue = 'One';
  var friends = [];
  final isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
        }
        Navigator.of(context).pushNamed("/");
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Kullanıcı Ara',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.white,
          actions: [
            // Navigate to the Search Screen
            IconButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(Constants.SEARCH_PAGE_PATH, arguments: friends),
              icon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
        body: StreamBuilder(
          stream: getFriends(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              friends = (snapshot.data as DocumentSnapshot)["friends"];
              return StreamBuilder(
                stream: getAllUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      key: const PageStorageKey<String>("page"),
                      padding: const EdgeInsets.all(10.0),
                      itemCount:
                          (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                              .docs
                              .length,
                      itemBuilder: (context, index) {
                        var name = (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
                            .docs[index]
                            .data()["name"]
                            .toString();
                        var userId = (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
                            .docs[index]
                            .id
                            .toString();

                        var profileImgUrl = (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
                            .docs[index]
                            .data()["profileImg"]
                            .toString();

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                Constants.PERSONAL_CHAT_PATH,
                                arguments: [
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userId
                                ]);
                          },
                          child: FirebaseAuth.instance.currentUser!.uid !=
                                      userId &&
                                  friends.contains(userId)
                              ? Dismissible(
                                  key: UniqueKey(),
                                  background: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 34,
                                      ),
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 34,
                                      ),
                                    ],
                                  ),
                                  onDismissed: (direction) {
                                    removeFriend(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userId,
                                        context,
                                        false);
                                  },
                                  child: Card(
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
                                          "$name $userId",
                                        ),
                                        // BURDA STREAMBUİLDER ILE GETLASTMESSAGE DINLI
                                        // O DA SON MESAJIN OLDUGU SNAPSHOTU DONSUN

                                        subtitle: Text("sdadasdad"),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        );
                      },
                    );
                  }
                },
              );
            } else {
              return const Text("nope");
            }
          },
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_arrow,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(Constants.SEARCH_PAGE_PATH, arguments: friends);
              },
              child: const Icon(Icons.person),
              label: "Add Friend",
            ),
            SpeedDialChild(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(Constants.GROUP_CREATE_PAGE_PATH);
              },
              child: const Icon(Icons.group),
              label: "Group Message",
            ),
          ],
        ),
      ),
    );
  }
}

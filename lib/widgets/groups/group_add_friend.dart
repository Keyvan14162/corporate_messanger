import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class GroupAddFriend extends StatefulWidget {
  const GroupAddFriend(
      {required this.groupUserIdList, required this.groupId, Key? key})
      : super(key: key);
  final String groupId;
  final List<dynamic> groupUserIdList;

  @override
  State<GroupAddFriend> createState() => _GroupAddFriendState();
}

class _GroupAddFriendState extends State<GroupAddFriend> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Set<String> selectedUsersId = {};
  String groupName = "";
  var friends = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: ThemeData().primaryColor,
            )),
        title: Text(
          "Add Friends",
          style: TextStyle(color: ThemeData().primaryColor),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder(
              stream: getFriends(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
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
                          itemCount: (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
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

                            bool checkBoxValue = false;

                            bool isMe =
                                FirebaseAuth.instance.currentUser!.uid ==
                                    userId;

                            return friends.contains(userId) &&
                                    !isMe &&
                                    !widget.groupUserIdList.contains(userId)
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
                                          "$name $userId",
                                        ),
                                        trailing: StatefulBuilder(
                                          builder: (context, setState) {
                                            return Checkbox(
                                              value: checkBoxValue,
                                              onChanged: (val) {
                                                setState(
                                                  () {
                                                    checkBoxValue = val!;

                                                    if (checkBoxValue) {
                                                      selectedUsersId
                                                          .add(userId);
                                                    } else {
                                                      selectedUsersId
                                                          .remove(userId);
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () async {
                if (selectedUsersId.isNotEmpty) {
                  selectedUsersId.forEach((element) async {
                    await FirebaseFirestore.instance
                        .collection("groups")
                        .doc(widget.groupId)
                        .update({
                      "userIds": FieldValue.arrayUnion([element])
                    });
                  });

                  selectedUsersId.forEach((element) async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(element)
                        .update({
                      "groups": FieldValue.arrayUnion([widget.groupId])
                    });
                  });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                      MySnackbar.getSnackbar("Kişiler gruba eklendi."));
                }
              },
              label: const Text('Gruba Ekle'),
              icon: const Icon(Icons.group),
              backgroundColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}

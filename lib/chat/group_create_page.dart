import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/models/group_model.dart';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({Key? key}) : super(key: key);

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Set<String> selectedUsersId = {};
  String groupName = "";

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
        title: TextField(
          maxLines: 1,
          decoration: InputDecoration.collapsed(
            hintText: "Grup ismi giriniz",
          ),
          onChanged: (value) {
            groupName = value;
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder(
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

                      bool isMe =
                          FirebaseAuth.instance.currentUser!.uid == userId;

                      bool checkBoxValue = false;

                      return Card(
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
                            trailing: isMe
                                ? const SizedBox()
                                : StatefulBuilder(
                                    builder: (context, setState) {
                                      return Checkbox(
                                        value: checkBoxValue,
                                        onChanged: (val) {
                                          setState(
                                            () {
                                              checkBoxValue = val!;

                                              if (checkBoxValue) {
                                                selectedUsersId.add(userId);
                                              } else {
                                                selectedUsersId.remove(userId);
                                              }
                                              print(selectedUsersId);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                      );
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
                if (groupName.trim().isNotEmpty && groupName.length < 30) {
                  selectedUsersId.add(FirebaseAuth.instance.currentUser!.uid);
                  // Tek basına iken de grup olsuturabilsin
                  var groupId =
                      FirebaseFirestore.instance.collection("groups").doc().id;
                  var groupModel = GroupModel(
                    userIds: selectedUsersId.toList(),
                    groupId: groupId,
                    name: groupName.trim(),
                  );
                  Map<String, dynamic> newGroup = <String, dynamic>{};
                  newGroup["userIds"] = groupModel.userIds;
                  newGroup["groupId"] = groupModel.groupId;
                  newGroup["name"] = groupModel.name;

                  await FirebaseFirestore.instance
                      .collection("groups")
                      .doc(groupId)
                      .set(newGroup);
                  selectedUsersId.forEach((element) async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc("${element}")
                        .update({
                      "groups": FieldValue.arrayUnion([groupId])
                    });
                  });
                }
              },
              label: const Text('Grup Oluştur'),
              icon: const Icon(Icons.group),
              backgroundColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}

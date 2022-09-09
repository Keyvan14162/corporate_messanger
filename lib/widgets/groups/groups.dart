import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/group_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var groups = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Gruplar',
          style: TextStyle(color: ThemeData().primaryColor),
        ),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: getGroups(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            groups = (snapshot.data as DocumentSnapshot)["groups"];
            return StreamBuilder(
              stream: getAllGroups(),
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
                      var groupId =
                          (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .id
                              .toString();

                      var groupName =
                          (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["name"]
                              .toString();

                      List<dynamic> groupUserIdList =
                          (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["userIds"];

                      return groups.contains(groupId)
                          ? GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed(
                                Constants.GROUP_CHAT_PATH,
                                arguments: [
                                  groupId,
                                  groupName,
                                  groupUserIdList
                                ],
                              ),
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: ListTile(
                                    /*
                              leading: profileImgUrl.contains("null")
                                  ? const Icon(Icons.person)
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(profileImgUrl),
                                    ),
                                    */
                                    title: Text(
                                      // "$name $userId",
                                      groupId,
                                    ),
                                    subtitle: Text("sdadasdad"),
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
    );
  }
}

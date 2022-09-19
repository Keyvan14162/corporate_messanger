import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
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
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamed("/");
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Grups',
            style: TextStyle(color: Theme.of(context).primaryColor),
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
                        var groupId = (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
                            .docs[index]
                            .id
                            .toString();

                        var groupName = (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
                            .docs[index]
                            .data()["name"]
                            .toString();

                        List<dynamic> groupUserIdList = (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
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
                                  color: Theme.of(context).primaryColor,
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ListTile(
                                        title: Text(
                                          groupName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            const Text(
                                              "Grup members :  ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                            for (int i = 0;
                                                i < groupUserIdList.length;
                                                i++)
                                              FutureBuilder(
                                                future: getUserName(
                                                    groupUserIdList[i]),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Text(
                                                      "${snapshot.data}, ",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  } else {
                                                    return const SizedBox();
                                                  }
                                                },
                                              )
                                          ],
                                        )),
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
    );
  }
}

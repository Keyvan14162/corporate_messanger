import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/models/group_model.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({Key? key}) : super(key: key);

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final formKey = GlobalKey<FormState>();
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
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            decoration: const InputDecoration.collapsed(
              hintText: "Grup ismi giriniz",
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              groupName = value;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return "Lütfen Grup İsmini Belirtiniz";
              } else if (value.length > 40) {
                return "En fazla 40 karakter girebilirsiniz";
              } else {
                return null;
              }
            },
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Grup Kişilerini Ekleyiniz"),
          ),
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

                            return friends.contains(userId)
                                ? GestureDetector(
                                    child: Card(
                                      elevation: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: ListTile(
                                          leading: profileImgUrl
                                                  .contains("null")
                                              ? const Icon(Icons.person)
                                              : CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      profileImgUrl),
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
                createGroup();
              },
              label: const Text('Grup Oluştur'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  createGroup() async {
    bool validate = formKey.currentState!.validate();

    if (validate) {
      formKey.currentState!.save();
      selectedUsersId.add(FirebaseAuth.instance.currentUser!.uid);
      // Tek basına iken de grup olsuturabilsin
      var groupId = FirebaseFirestore.instance.collection("groups").doc().id;
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
            .doc(element)
            .update({
          "groups": FieldValue.arrayUnion([groupId])
        });
      });

      formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackbar.getSnackbar("$groupName grubu oluşturuldu."),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackbar.getSnackbar("Grup Oluşturulamadı"),
      );
    }
  }
}

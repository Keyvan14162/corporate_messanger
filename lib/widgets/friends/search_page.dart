import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class SearchPage extends StatefulWidget {
  SearchPage({required this.friends, Key? key}) : super(key: key);
  List<dynamic> friends;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _textController;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The search area here
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),

        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(80),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              controller: _textController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    setState(() {
                      _textController.clear();
                    });
                  },
                ),
                hintText: 'Ara...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              // to preserve scroll position
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
                    if (widget.friends.contains(userId)) {
                      Navigator.of(context).pushNamed(
                          Constants.PERSONAL_CHAT_PATH,
                          // tıklayan, tıklanan
                          arguments: [
                            FirebaseAuth.instance.currentUser!.uid,
                            userId
                          ]);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        MySnackbar.getSnackbar("Önce arkadaş eklemelisiniz"),
                      );
                    }
                  },
                  child: FirebaseAuth.instance.currentUser!.uid != userId
                      ? name.contains(searchText)
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
                                    trailing: StreamBuilder(
                                      stream: getFriends(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return IconButton(
                                            onPressed: () {},
                                            icon: (snapshot.data
                                                            as DocumentSnapshot)[
                                                        "friends"]
                                                    .contains(userId)
                                                ? Icon(
                                                    Icons.check,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    size: 34,
                                                  )
                                                : IconButton(
                                                    onPressed: () async {
                                                      addUserToFriends(userId);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(MySnackbar
                                                              .getSnackbar(
                                                                  "$name arkadaş olarak eklendi"));
                                                    },
                                                    icon: const Icon(
                                                      Icons.person_add_alt,
                                                    ),
                                                  ),
                                          );
                                        } else {
                                          return const Text("nope");
                                        }
                                      },
                                    )),
                              ),
                            )
                          : const SizedBox()
                      : const SizedBox(),
                );
              },
            );
          }
        },
      ),
    );
  }
}

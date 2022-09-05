import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/model/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

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
          color: ThemeData().primaryColor, //change your color here
        ),

        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: ThemeData().primaryColor.withOpacity(0.3),
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
        stream: getFilteredUsers(),
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
                    Navigator.of(context).pushNamed("/personalChat",
                        // tıklayan, tıklanan
                        arguments: [
                          FirebaseAuth.instance.currentUser!.uid,
                          userId
                        ]);
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
                                ),
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

  getFilteredUsers() {
    var userStream = FirebaseFirestore.instance.collection("users").snapshots();
    return userStream;
  }

  Future<String> getUserName(String userId) async {
    // one time read
    var name = (await FirebaseFirestore.instance.doc("users/$userId").get())
        .data()!["name"];

    return name;
  }
}

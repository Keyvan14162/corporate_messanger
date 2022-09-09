import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class PersonalChat extends StatefulWidget {
  const PersonalChat(
      {required this.senderId, required this.reciverId, Key? key})
      : super(key: key);
  final String senderId;
  final String reciverId;

  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? userSubscribe;
  late TextEditingController _textController;
  bool hoverd = false;
  String _message = "";
  Set<String> selectedMessagesId = {};
  Set<String> selectedMessagesImgUrl = {};
  var readCounter = 0;
  var writeCounter = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: Container(
        // color: Colors.green.shade100,
        child: Column(
          children: [
            Flexible(
              child: StreamBuilder(
                stream: getAllMessages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      thickness: 5,
                      radius: const Radius.circular(10),
                      child: ListView.builder(
                        // to preserve scroll position
                        key: const PageStorageKey<String>("page"),
                        reverse: true,

                        padding: const EdgeInsets.all(10.0),
                        itemCount: (snapshot.data
                                as QuerySnapshot<Map<String, dynamic>>)
                            .docs
                            .length,
                        itemBuilder: (context, index) {
                          var message = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["message"]
                              .toString();

                          Timestamp timestamp = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["date"] as Timestamp;

                          var date =
                              "${timestamp.toDate().year.toString()}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().day.toString().padLeft(2, '0')} ${timestamp.toDate().hour.toString().padLeft(2, '0')}-${timestamp.toDate().minute.toString().padLeft(2, '0')}";

                          var senderId = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["senderId"]
                              .toString();

                          var messageId = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["messageId"]
                              .toString();

                          var isSender =
                              FirebaseAuth.instance.currentUser!.uid ==
                                  senderId;

                          var isImg = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["isImg"]
                              .toString();

                          var isReaded = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["isReaded"]
                              .toString();

                          String imgUrl = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["imgUrl"]
                              .toString();

                          return messageWidget(
                            isSender,
                            senderId,
                            isImg,
                            imgUrl,
                            message,
                            date,
                            messageId,
                            isReaded,
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            // Text field
            textFieldMessage(),
          ],
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      // automaticallyImplyLeading: false,
      leadingWidth: 30,
      leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back)),
      title: Row(
        children: [
          FutureBuilder(
              future: getUserField(widget.reciverId, "profileImg"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data.toString()),
                    ),
                  );
                } else {
                  return const Icon(Icons.person);
                }
              }),
          FutureBuilder(
            future: getUserField(widget.reciverId, "name"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toString());
              } else {
                return Text("No name found");
              }
            },
          ),
        ],
      ),
      actions: [
        hoverd
            ? Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _deleteSelectedMessages();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        hoverd = !hoverd;
                        selectedMessagesId = {};
                        selectedMessagesImgUrl = {};
                      });
                    },
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.only(right: 10),
                child: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("AAAAAAAAAAA"),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: ThemeData().primaryColor,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () async {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text("BBBBBBBBB"),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: ThemeData().primaryColor,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ],
    );
  }

  Container textFieldMessage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red.withOpacity(0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blue.shade100,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Write message...",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      _message = value.toString();
                    },
                    // dont dismisss keyboard
                    onEditingComplete: () {},
                    onSubmitted: (value) {
                      sendMessage(_message, false, "imgUrl", widget.senderId,
                          widget.reciverId);
                      _textController.clear();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Container(
              height: 55,
              width: 55,
              padding: const EdgeInsets.only(right: 10),
              child: PopupMenuButton(
                icon: const Icon(Icons.camera),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () async {
                      _sendImageOnTap(ImageSource.camera);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          color: ThemeData().primaryColor,
                        ),
                        const Text("Kamera"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () async {
                      _sendImageOnTap(ImageSource.gallery);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.image,
                          color: ThemeData().primaryColor,
                        ),
                        const Text("Galeri"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 55,
              width: 55,
              padding: const EdgeInsets.only(right: 10),
              child: FloatingActionButton(
                onPressed: () {
                  sendMessage(_message, false, "imgUrl", widget.senderId,
                      widget.reciverId);
                  _textController.clear();
                },
                backgroundColor: Colors.blue,
                elevation: 0,
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding messageWidget(
    bool isSender,
    String senderId,
    String isImg,
    String imgUrl,
    String message,
    String date,
    String messageId,
    String isReaded,
  ) {
    bool checkboxValue = false;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        alignment: isSender ? Alignment.topRight : Alignment.topLeft,
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            isSender
                ? const SizedBox()
                : FutureBuilder(
                    future: getUserName(senderId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.toString());
                      } else {
                        return const Text("No Name Found");
                      }
                    }),
            isImg == "true"
                ? GestureDetector(
                    onLongPress: () {
                      setState(() {
                        hoverd = !hoverd;
                      });
                    },
                    onTap: () {
                      if (hoverd) {
                        setState(() {
                          hoverd = !hoverd;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  Constants.IMG_PAGE_PATH,
                                  arguments: imgUrl);
                            },
                            child: Hero(
                              tag: imgUrl,
                              child: Container(
                                padding: isSender
                                    ? const EdgeInsets.fromLTRB(48, 8, 8, 8)
                                    : const EdgeInsets.fromLTRB(8, 8, 48, 8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Image.network(
                                  imgUrl,
                                ),
                              ),
                            ),
                          ),
                        ),
                        hoverd
                            ? StatefulBuilder(builder: (context, setState) {
                                return isSender
                                    ? Checkbox(
                                        value: checkboxValue,
                                        onChanged: (val) {
                                          setState(() {
                                            checkboxValue = val!;
                                            if (checkboxValue) {
                                              selectedMessagesId.add(messageId);
                                              selectedMessagesImgUrl
                                                  .add(imgUrl);
                                            } else {
                                              selectedMessagesId
                                                  .remove(messageId);
                                              selectedMessagesImgUrl
                                                  .remove(imgUrl);
                                            }
                                          });
                                        })
                                    : const SizedBox();
                              })
                            : const SizedBox(),
                      ],
                    ))
                : Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  hoverd = !hoverd;
                                });
                              },
                              onTap: () {
                                if (hoverd) {
                                  setState(() {
                                    hoverd = !hoverd;
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: isSender
                                        ? const Radius.circular(0)
                                        : const Radius.circular(8),
                                    topLeft: isSender
                                        ? const Radius.circular(8)
                                        : const Radius.circular(0),
                                    bottomLeft: const Radius.circular(8),
                                    bottomRight: const Radius.circular(8),
                                  ),
                                  color: (isSender
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade300),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        message,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            date.toString(),
                                            style: const TextStyle(
                                              fontSize: 8,
                                              //color: Colors.grey,
                                            ),
                                          ),
                                          isSender
                                              ? isReaded == "true"
                                                  ? const Icon(
                                                      Icons.double_arrow,
                                                      color: Colors.red,
                                                      size: 12,
                                                    )
                                                  : const Icon(
                                                      Icons.double_arrow,
                                                      color: Colors.grey,
                                                      size: 12,
                                                    )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          hoverd
                              ? StatefulBuilder(builder: (context, setState) {
                                  return isSender
                                      ? Checkbox(
                                          value: checkboxValue,
                                          onChanged: (val) {
                                            setState(() {
                                              checkboxValue = val!;
                                              // img degil
                                              if (checkboxValue) {
                                                selectedMessagesId
                                                    .add(messageId);
                                              } else {
                                                selectedMessagesId
                                                    .remove(messageId);
                                              }
                                            });
                                          })
                                      : const SizedBox();
                                })
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  _sendImageOnTap(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);

    var profileRef = FirebaseStorage.instance.ref(
        "users/messagePics/${FirebaseAuth.instance.currentUser!.uid}/${firestore.collection("users").doc().id}");
    var task = profileRef.putFile(File(file!.path));

    task.whenComplete(() async {
      var url = await profileRef.getDownloadURL();

      await sendMessage(
          "message", true, url, widget.senderId, widget.reciverId);
    });
  }

  // HER SEFERINDE ISTEK YOLLAMASIN DYUZELT BUNU
  // SENDERNAME DİGER SINIFTAN YOLLASIN YADA BURDA 1 KERE TANIMLA
  Future<String> getUserField(String userId, String fieldName) async {
    // one time read
    var data =
        (await FirebaseFirestore.instance.doc("users/$userId").get()).data()!;

    return data[fieldName];
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    var messageStream = firestore
        .collection("personal_chat")
        .doc("${widget.senderId + "-" + widget.reciverId}")
        .collection("messages")
        .orderBy("date", descending: true)
        .snapshots();

    return messageStream;
  }

  _deleteSelectedMessages() async {
    if (selectedMessagesId.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Uyarı"),
          content: Text("Seçilen Mesajlar silinsin mi ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hayır"),
            ),
            TextButton(
              onPressed: () {
                // delete from storage
                if (selectedMessagesImgUrl.isNotEmpty) {
                  selectedMessagesImgUrl.forEach((url) async {
                    if (url != "imgUrl") {
                      await FirebaseStorage.instance.refFromURL(url).delete();
                    }
                  });
                }
                // delete from firebase
                selectedMessagesId.forEach((messageId) async {
                  await firestore
                      .collection("personal_chat")
                      .doc("${widget.senderId + "-" + widget.reciverId}")
                      .collection("messages")
                      .doc(messageId)
                      .delete();
                  await firestore
                      .collection("personal_chat")
                      .doc("${widget.reciverId + "-" + widget.senderId}")
                      .collection("messages")
                      .doc(messageId)
                      .delete();
                });

                setState(() {
                  hoverd = !hoverd;
                  selectedMessagesId = {};
                  selectedMessagesImgUrl = {};
                });

                Navigator.of(context).pop();
              },
              child: const Text("Evet"),
            ),
          ],
        ),
      );
    }
  }
}

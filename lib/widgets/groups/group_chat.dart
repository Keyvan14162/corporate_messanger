import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/helpers/group_helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class GroupChat extends StatefulWidget {
  const GroupChat(
      {required this.groupUserIdList,
      required this.groupName,
      required this.groupId,
      Key? key})
      : super(key: key);

  final String groupId;
  final String groupName;
  final List<dynamic> groupUserIdList;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TextEditingController _textController;
  bool hoverd = false;
  String _message = "";
  Set<String> selectedMessagesId = {};
  Set<String> selectedMessagesImgUrl = {};

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
                stream: getAllGroupMessages(widget.groupId),
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

                          if (!isSender) {
                            // karsıdan gelen mesajlar isreaded olsun
                            /*
                            setMessagesReaded(
                                widget.senderId, widget.reciverId, messageId);
                                */
                          }

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
        icon: const Icon(Icons.arrow_back),
      ),
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.groupName),
              Row(
                children: [
                  for (int i = 0; i < widget.groupUserIdList.length; i++)
                    FutureBuilder(
                      future: getUserName(widget.groupUserIdList[i]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data.toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    )
                ],
              )
            ],
          ),
        ],
      ),
      actions: [
        hoverd
            ? Row(
                children: [
                  IconButton(
                    onPressed: () {
                      deleteSelectedMessages();
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
                      key: UniqueKey(),
                      onTap: () {
                        leaveGroup(widget.groupId, context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Leave Group"),
                          Icon(
                            Icons.exit_to_app,
                            color: ThemeData().primaryColor,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      key: UniqueKey(),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            Constants.GROUP_ADD_FRIEND_PATH,
                            arguments: [
                              widget.groupId,
                              widget.groupUserIdList
                            ]);
                        Navigator.of(context).pushNamed(
                            Constants.GROUP_ADD_FRIEND_PATH,
                            arguments: [
                              widget.groupId,
                              widget.groupUserIdList
                            ]);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Add Friend"),
                          Icon(
                            Icons.person_add_alt_1_outlined,
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
                    onSubmitted: (value) async {
                      await sendGroupMessage(
                        _message,
                        false,
                        "imgUrl",
                        FirebaseAuth.instance.currentUser!.uid,
                        widget.groupId,
                        widget.groupId,
                      );
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
                      sendGroupImageOnTap(ImageSource.camera, widget.groupId);
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
                      sendGroupImageOnTap(ImageSource.gallery, widget.groupId);
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
                  sendGroupMessage(
                    _message,
                    false,
                    "imgUrl",
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.groupId,
                    widget.groupId,
                  );
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
                    },
                  ),
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
                            ? StatefulBuilder(
                                builder: (context, setState) {
                                  return isSender
                                      ? Checkbox(
                                          value: checkboxValue,
                                          onChanged: (val) {
                                            setState(() {
                                              checkboxValue = val!;
                                              if (checkboxValue) {
                                                selectedMessagesId
                                                    .add(messageId);
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
                                },
                              )
                            : const SizedBox(),
                      ],
                    ),
                  )
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

  deleteSelectedMessages() async {
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
                      .collection("groups")
                      .doc(widget.groupId)
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

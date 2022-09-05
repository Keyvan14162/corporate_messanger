import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/model/message_model.dart';
import 'package:image_picker/image_picker.dart';

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
  Set<String> selectedMessages = {};

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: true,
        leading: FutureBuilder(
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
        title: FutureBuilder(
          future: getUserField(widget.reciverId, "name"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toString());
            } else {
              return Text("No name found");
            }
          },
        ),
        actions: [
          hoverd
              ? const SizedBox()
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
          hoverd
              ? IconButton(
                  onPressed: () {
                    _deleteSelectedMessages();
                  },
                  icon: const Icon(Icons.delete))
              : const SizedBox()
        ],
      ),
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

                          String imgUrl = (snapshot.data
                                  as QuerySnapshot<Map<String, dynamic>>)
                              .docs[index]
                              .data()["imgUrl"]
                              .toString();

                          return messageWidget(isSender, senderId, isImg,
                              imgUrl, message, date, messageId);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            // Text field
            Container(
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
                            onSubmitted: (value) {
                              sendMessage(_message, false, "imgUrl");
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
                              _kameraOnTap(ImageSource.camera);
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
                              _kameraOnTap(ImageSource.gallery);
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
                        heroTag: "btn2",
                        onPressed: () {
                          sendMessage(_message, false, "imgUrl");
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
            FutureBuilder(
                future: getUserField(senderId, "name"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  } else {
                    return const Text("No Name Found");
                  }
                }),
            Text("sender id - $senderId"),
            isImg == "true"
                ? Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Image.network(
                      imgUrl,
                    ),
                  )
                : Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
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
                                key: const ValueKey(2),
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          hoverd
                              ? StatefulBuilder(builder: (context, setState) {
                                  return Checkbox(
                                      value: checkboxValue,
                                      onChanged: (val) {
                                        setState(() {
                                          checkboxValue = val!;
                                          if (checkboxValue) {
                                            selectedMessages.add(messageId);
                                          } else {
                                            selectedMessages.remove(messageId);
                                          }
                                          print(selectedMessages);
                                        });
                                      });
                                })
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
            Text(
              date.toString(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  _kameraOnTap(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);

    var profileRef = FirebaseStorage.instance.ref(
        "users/messagePics/${FirebaseAuth.instance.currentUser!.uid}/${firestore.collection("users").doc().id}");
    var task = profileRef.putFile(File(file!.path));

    task.whenComplete(() async {
      var url = await profileRef.getDownloadURL();

      await sendMessage("message", true, url);
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

  sendMessage(String message, bool isImg, String imgUrl) async {
    if (message.isNotEmpty) {
      // dbye mesajı yazdır

      // IKI MESSAGENIN DE IDSI AYNI , SILME SISTEMINI EKLE
      var messageId = firestore
          .collection("personal_chat")
          .doc("${widget.senderId + "-" + widget.reciverId}")
          .collection("messages")
          .doc()
          .id;

      var messageModel = MessageModel(
        reciverId: widget.reciverId,
        senderId: widget.senderId,
        message: message,
        date: Timestamp.now(),
        imgurl: imgUrl,
        isImg: isImg,
        messageId: messageId,
      );

      Map<String, dynamic> newMessage = <String, dynamic>{};
      newMessage["message"] = messageModel.message;
      newMessage["senderId"] = messageModel.senderId;
      newMessage["date"] = messageModel.date;
      newMessage["reciverId"] = messageModel.reciverId;
      newMessage["isImg"] = messageModel.isImg;
      newMessage["imgUrl"] = messageModel.imgurl;
      newMessage["messageId"] = messageModel.messageId;

      //   await firestore.collection("chat").add(newMessage);

      // her mesajda ilk once hangi id gelmedigini bilmedigim icin
      // iki ihtimale karsı iki ekleme yapıyor.
      // kısa yolu var mı bulamadım.
      await firestore
          .collection("personal_chat")
          .doc("${widget.senderId + "-" + widget.reciverId}")
          .collection("messages")
          .doc(messageId)
          .set(newMessage);

      await firestore
          .collection("personal_chat")
          .doc("${widget.reciverId + "-" + widget.senderId}")
          .collection("messages")
          .doc(messageId)
          .set(newMessage);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    String docpath = "";
    var messageStream = firestore
        .collection("personal_chat")
        .doc("${widget.senderId + "-" + widget.reciverId}")
        .collection("messages")
        .orderBy("date", descending: true)
        .snapshots();

    return messageStream;
  }

  _deleteSelectedMessages() async {
    if (selectedMessages.isNotEmpty) {
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
                selectedMessages.forEach((messageId) async {
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
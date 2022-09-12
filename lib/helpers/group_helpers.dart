import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/models/message_model.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';
import 'package:image_picker/image_picker.dart';

//
sendGroupImageOnTap(ImageSource source, String groupId) async {
  final ImagePicker picker = ImagePicker();
  XFile? file = await picker.pickImage(source: source);

  var profileRef = FirebaseStorage.instance.ref(
      "users/messagePics/${FirebaseAuth.instance.currentUser!.uid}/${FirebaseFirestore.instance.collection("groups").doc().id}");
  var task = profileRef.putFile(File(file!.path));
  print(task);

  task.whenComplete(() async {
    var url = await profileRef.getDownloadURL();

    await sendGroupMessage("message", true, url,
        FirebaseAuth.instance.currentUser!.uid, groupId, groupId);
  });
}

//
sendGroupMessage(String message, bool isImg, String imgUrl, String senderId,
    String reciverId, String groupId) async {
  if (message.isNotEmpty) {
    // dbye mesajı yazdır

    // IKI MESSAGENIN DE IDSI AYNI , SILME SISTEMINI EKLE
    var messageId = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .doc()
        .id;

    var messageModel = MessageModel(
      reciverId: reciverId,
      senderId: senderId,
      message: message,
      date: Timestamp.now(),
      imgurl: imgUrl,
      isImg: isImg,
      messageId: messageId,
      isReaded: false,
    );

    Map<String, dynamic> newMessage = <String, dynamic>{};
    newMessage["message"] = messageModel.message;
    newMessage["senderId"] = messageModel.senderId;
    newMessage["date"] = messageModel.date;
    newMessage["reciverId"] = messageModel.reciverId;
    newMessage["isImg"] = messageModel.isImg;
    newMessage["imgUrl"] = messageModel.imgurl;
    newMessage["messageId"] = messageModel.messageId;
    newMessage["isReaded"] = messageModel.isReaded;

    //   await firestore.collection("chat").add(newMessage);

    // her mesajda ilk once hangi id gelmedigini bilmedigim icin
    // iki ihtimale karsı iki ekleme yapıyor.
    // kısa yolu var mı bulamadım.
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .doc(messageId)
        .set(newMessage);
  }
}

//
Stream<QuerySnapshot<Map<String, dynamic>>> getAllGroupMessages(
    String groupId) {
  var messageStream = FirebaseFirestore.instance
      .collection("groups")
      .doc(groupId)
      .collection("messages")
      .orderBy("date", descending: true)
      .snapshots();

  return messageStream;
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getGroups() {
  var groups = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  return groups;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getAllGroups() {
  var groupStream = FirebaseFirestore.instance.collection("groups").snapshots();

  return groupStream;
}

leaveGroup(String groupId, BuildContext context) async {
  var messages = await FirebaseFirestore.instance
      .collection("groups")
      .doc(groupId)
      .collection("messages")
      .orderBy("date", descending: true)
      .get();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Uyarı"),
      content: Text("Gruptan ayrılınsın mı ?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Hayır"),
        ),
        TextButton(
          onPressed: () async {
            // delete from storage
            /*
              messages.docs.forEach((element) async {
                var url = element.data()["imgUrl"];

                if (url != "imgUrl") {
                  await FirebaseStorage.instance.refFromURL(url).delete();
                }
              });
              */

            // delete from firebase
            /*
              messages.docs.forEach((element) async {
                var messageId = element.data()["messageId"];

                await firestore
                    .collection("groups")
                    .doc("${groupId}")
                    .collection("messages")
                    .doc(messageId)
                    .delete();
              });
              */

            await FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              "groups": FieldValue.arrayRemove([groupId])
            });

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context)
                .showSnackBar(MySnackbar.getSnackbar("Gruptan ayrıldın."));
          },
          child: const Text("Evet"),
        ),
      ],
    ),
  );
}

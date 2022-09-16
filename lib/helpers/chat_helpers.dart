import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/models/message_model.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

//
getAllUsers() {
  var userStream = FirebaseFirestore.instance.collection("users").snapshots();

  return userStream;
}

//
Stream<DocumentSnapshot<Map<String, dynamic>>> getFriends() {
  var friends = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  return friends;
}

sendMessage(String message, bool isImg, String imgUrl, String senderId,
    String reciverId) async {
  if (message.isNotEmpty) {
    // dbye mesajı yazdır

    // IKI MESSAGENIN DE IDSI AYNI , SILME SISTEMINI EKLE
    var messageId = FirebaseFirestore.instance
        .collection("personal_chat")
        .doc("$senderId-$reciverId")
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
        .collection("personal_chat")
        .doc("$senderId-$reciverId")
        .collection("messages")
        .doc(messageId)
        .set(newMessage);

    await FirebaseFirestore.instance
        .collection("personal_chat")
        .doc("$reciverId-$senderId")
        .collection("messages")
        .doc(messageId)
        .set(newMessage);
  }
}

getAllMessages() {
  var messageStream = FirebaseFirestore.instance
      .collection("chat")
      .orderBy("date", descending: true)
      .snapshots();
  return messageStream;
}

//
Future<String> getUserName(String userId) async {
  // one time read
  var name = (await FirebaseFirestore.instance.doc("users/$userId").get())
      .data()!["name"];

  return name;
}

addUserToFriends(String addUserId) async {
  // lets make both friends
  await FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .update({
    "friends": FieldValue.arrayUnion([addUserId])
  });

  await FirebaseFirestore.instance.collection("users").doc(addUserId).update({
    "friends": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
  });
}

removeFriend(String senderId, String reciverId, BuildContext context,
    bool doublePop) async {
  var messages = await FirebaseFirestore.instance
      .collection("personal_chat")
      .doc("$senderId-$reciverId")
      .collection("messages")
      .orderBy("date", descending: true)
      .get();

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
          onPressed: () async {
            // delete from storage
            messages.docs.forEach((element) async {
              var url = element.data()["imgUrl"];

              if (url != "imgUrl") {
                await FirebaseStorage.instance.refFromURL(url).delete();
              }
            });

            // delete from firebase
            messages.docs.forEach((element) async {
              var messageId = element.data()["messageId"];

              await FirebaseFirestore.instance
                  .collection("personal_chat")
                  .doc("$senderId-$reciverId")
                  .collection("messages")
                  .doc(messageId)
                  .delete();
              await FirebaseFirestore.instance
                  .collection("personal_chat")
                  .doc("$reciverId-$senderId")
                  .collection("messages")
                  .doc(messageId)
                  .delete();
            });

            await FirebaseFirestore.instance
                .collection("users")
                .doc(senderId)
                .update({
              "friends": FieldValue.arrayRemove([reciverId])
            });
            await FirebaseFirestore.instance
                .collection("users")
                .doc(reciverId)
                .update({
              "friends": FieldValue.arrayRemove([senderId])
            });

            Navigator.of(context).pop();

            if (doublePop) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: const Text("Evet"),
        ),
      ],
    ),
  );
}

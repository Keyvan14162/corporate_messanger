import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/models/message_model.dart';

getAllUsers() {
  var userStream = FirebaseFirestore.instance.collection("users").snapshots();

  return userStream;
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getFriends() {
  var friends = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  return friends;
}

// perssonal_chatden bakarak ekleme yap

sendMessage(String message, bool isImg, String imgUrl, String senderId,
    String reciverId) async {
  if (message.isNotEmpty) {
    // dbye mesajı yazdır

    // IKI MESSAGENIN DE IDSI AYNI , SILME SISTEMINI EKLE
    var messageId = FirebaseFirestore.instance
        .collection("personal_chat")
        .doc("${senderId + "-" + reciverId}")
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
        .doc("${senderId + "-" + reciverId}")
        .collection("messages")
        .doc(messageId)
        .set(newMessage);

    await FirebaseFirestore.instance
        .collection("personal_chat")
        .doc("${reciverId + "-" + senderId}")
        .collection("messages")
        .doc(messageId)
        .set(newMessage);
  }
}

sendGroupMessage(String message, bool isImg, String imgUrl, String senderId,
    String reciverId, String groupId) async {
  if (message.isNotEmpty) {
    // dbye mesajı yazdır

    // IKI MESSAGENIN DE IDSI AYNI , SILME SISTEMINI EKLE
    var messageId = FirebaseFirestore.instance
        .collection("groups")
        .doc("${groupId}")
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
        .doc("${groupId}")
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
      .doc("${FirebaseAuth.instance.currentUser!.uid}")
      .update({
    "friends": FieldValue.arrayUnion([addUserId])
  });

  await FirebaseFirestore.instance
      .collection("users")
      .doc("${addUserId}")
      .update({
    "friends": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
  });
}

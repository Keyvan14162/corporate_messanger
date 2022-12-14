import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String message;
  final Timestamp date;
  final String reciverId;
  final bool isImg;
  final String imgurl;
  final String messageId;
  final bool isReaded;

  MessageModel({
    required this.isReaded,
    required this.messageId,
    required this.isImg,
    required this.imgurl,
    required this.reciverId,
    required this.senderId,
    required this.message,
    required this.date,
  });
}

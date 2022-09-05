// Bunu sadece db ye veri eklerken kullanacagız
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final int age;
  // final List positions;
  // final int loginCount;
  // default img
  List<String> friends;

  UserModel({
    required this.friends,
    required this.name,
    required this.age,
    // required this.positions,
    // required this.loginCount,
  });
}

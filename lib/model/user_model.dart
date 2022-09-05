// Bunu sadece db ye veri eklerken kullanacagız
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final int age;
  // final List positions;
  // final int loginCount;
  // default img

  UserModel({
    required this.name,
    required this.age,
    // required this.positions,
    // required this.loginCount,
  });
}

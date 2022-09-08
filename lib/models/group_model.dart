// Bunu sadece db ye veri eklerken kullanacagız
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final List<String> userIds;
  final String groupId;

  GroupModel({
    required this.userIds,
    required this.groupId,
  });
}

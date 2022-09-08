// Bunu sadece db ye veri eklerken kullanacagız

class UserModel {
  final String name;
  final int age;
  // final List positions;
  // final int loginCount;
  // default img
  List<String> friends;
  List<String> groups;

  UserModel({
    required this.friends,
    required this.groups,
    required this.name,
    required this.age,
    // required this.positions,
    // required this.loginCount,
  });
}

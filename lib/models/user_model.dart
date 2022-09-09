class UserModel {
  final String name;
  final int age;

  List<String> friends;
  List<String> groups;

  UserModel({
    required this.friends,
    required this.groups,
    required this.name,
    required this.age,
  });
}

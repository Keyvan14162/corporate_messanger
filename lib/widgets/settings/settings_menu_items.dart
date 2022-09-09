import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class SettingsMenuItems extends StatefulWidget {
  const SettingsMenuItems({Key? key}) : super(key: key);

  @override
  State<SettingsMenuItems> createState() => _SettingsMenuItemsState();
}

class _SettingsMenuItemsState extends State<SettingsMenuItems> {
  late FirebaseAuth auth;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Change user informations
        createButton("Change User Informations", Icons.edit, () {
          Navigator.of(context).pushNamed(Constants.USER_UPDATE_PATH,
              arguments: auth.currentUser!.uid);
        }),

        // Sign out user
        createButton("Sign Out cıkıs yap", Icons.exit_to_app, () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Uyarı"),
              content: Text("Çıkış yapmak istediğinize emin misiniz ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Hayır"),
                ),
                TextButton(
                  onPressed: () {
                    signOutUser();
                    Navigator.of(context).pop();
                    showMessageAyarlar(
                        "${auth.currentUser!.email} çıkış yaptı", context);
                  },
                  child: const Text("Evet"),
                ),
              ],
            ),
          );
        }),

        // Delete user
        createButton("Delete User", Icons.delete, () async {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Uyarı"),
              content: Text("Hesabınızı silmek istediğinize emin misiniz ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Hayır"),
                ),
                TextButton(
                  onPressed: () async {
                    var sonuc = await deleteUser(context);
                    if (sonuc) {
                      Navigator.of(context).pop();
                      showMessageAyarlar("silindi", context);
                    }
                  },
                  child: const Text("Evet"),
                ),
              ],
            ),
          );
        }),

        // Hesap Doğrulama
        createButton("Hesap Dogrulama", Icons.account_box, () async {
          setState(() {
            hesapDogrula(context);
          });
        }),

        // Password Change 141622
        createButton("Sifre degistir", Icons.password, () async {
          Navigator.of(context)
              .pushNamed(Constants.PASSWORD_CHANGE_PATH, arguments: auth);
        }),

        // Mail Change
        createButton("Mail Değiştir", Icons.mail, () async {
          Navigator.of(context)
              .pushNamed(Constants.MAIL_CHNAGE_PATH, arguments: auth);
        })
      ],
    );
  }

  Column createButton(String message, IconData iconData, Function function) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              function();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(iconData, color: Colors.blue.shade500),
                const SizedBox(
                  width: 30,
                  height: 0,
                ),
                Text(
                  message,
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Divider(
            height: 0,
            color: Colors.grey.shade500,
            thickness: 0.2,
          ),
        ),
      ],
    );
  }
}

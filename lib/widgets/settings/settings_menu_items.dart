import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class SettingsMenuItems extends StatefulWidget {
  const SettingsMenuItems({Key? key}) : super(key: key);

  @override
  State<SettingsMenuItems> createState() => _SettingsMenuItemsState();
}

class _SettingsMenuItemsState extends State<SettingsMenuItems> {
  late FirebaseAuth auth;
  final String providerId =
      FirebaseAuth.instance.currentUser!.providerData[0].providerId;
  // password
  // google.com
  // phone

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
          Navigator.of(context).pushNamed(Constants.USER_UPDATE_PATH);
        }),

        // Hesap Doğrulama
        (providerId != "phone")
            ? createButton("Account Verification", Icons.account_box, () async {
                setState(() {
                  hesapDogrula(context);
                });
              })
            : const SizedBox(),

        // Mail Change
        (providerId == "password")
            ? createButton("Change Mail", Icons.mail, () async {
                Navigator.of(context)
                    .pushNamed(Constants.MAIL_CHNAGE_PATH, arguments: auth);
              })
            : const SizedBox(),

        // Password Change 141622
        (providerId == "password")
            ? createButton("Change Password", Icons.password, () async {
                Navigator.of(context)
                    .pushNamed(Constants.PASSWORD_CHANGE_PATH, arguments: auth);
              })
            : const SizedBox(),

        // Sign out user
        createButton("Sign Out", Icons.exit_to_app, () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Warning"),
              content: Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    signOutUser();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      MySnackbar.getSnackbar(
                          "${auth.currentUser!.email} signed out."),
                    );
                  },
                  child: const Text("Yes"),
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
              title: Text("Warning"),
              content: Text("Are you sure you want to delete your account ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () async {
                    var sonuc = await deleteUser(context);
                    if (sonuc) {
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        MySnackbar.getSnackbar("Deleted."),
                      );
                    }
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
          );
        }),
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
                Icon(
                  iconData,
                  color: Theme.of(context).primaryColor.withAlpha(500),
                ),
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

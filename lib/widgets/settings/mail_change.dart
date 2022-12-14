import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class MailChange extends StatefulWidget {
  const MailChange({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  State<MailChange> createState() => _MailChangeState();
}

class _MailChangeState extends State<MailChange> {
  final formKey = GlobalKey<FormState>();

  String _yeniMail = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          // reverse: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  // yeni sifre
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "New mail",
                      hintText: "New mail",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (deger) {
                      _yeniMail = deger!;
                    },
                    validator: (deger) {
                      if (deger!.length < 10) {
                        return "Mail can't be smaller than 10 chracters";
                      } else {
                        return null;
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // degistir buton
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(10),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    onPressed: () async {
                      bool validate = formKey.currentState!.validate();
                      formKey.currentState!.save();

                      if (validate) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Alert"),
                            content: Text(
                                "Are you sure taht you want to change your mail?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(Constants.SETTINGS_PATH);
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    MySnackbar.getSnackbar(
                                        "New mail : $_yeniMail"),
                                  );

                                  changeMail(_yeniMail, widget.auth, context);
                                  Navigator.of(context)
                                      .pushNamed(Constants.SETTINGS_PATH);
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.login, color: Colors.white),
                        Text(
                          "Change",
                          maxLines: 1,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

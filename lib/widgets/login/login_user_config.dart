import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase_auth/helpers/login_helpers.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class LoginUserConfig extends StatefulWidget {
  const LoginUserConfig({Key? key}) : super(key: key);

  @override
  State<LoginUserConfig> createState() => _LoginUserConfigState();
}

class _LoginUserConfigState extends State<LoginUserConfig> {
  @override
  void initState() {
    super.initState();
    print("-------------" + FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String _name = "";
    DateTime _birthdate = DateTime(2000);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fill the fields"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // profile img
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                    stream: getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return GestureDetector(
                          onTap: () {
                            chooseProfileImg(
                                FirebaseAuth.instance.currentUser!.uid);
                          },
                          child: CircleAvatar(
                            //  foregroundImage: ImageProvider(),
                            maxRadius: 80,
                            child: CircleAvatar(
                              radius: 144 / 2 + 10,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 144 / 2,
                                // backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  (snapshot.data
                                      as DocumentSnapshot)["profileImg"],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const CircleAvatar(
                          maxRadius: 80,
                          child: CircleAvatar(
                            radius: 144 / 2 + 10,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 144 / 2,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                // name
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      onSaved: (deger) {
                        _name = deger!;
                      },
                      validator: (deger) {
                        if (deger!.trim().isEmpty) {
                          return "Name can't be empty";
                        } else if (deger.length > 25) {
                          return "Name can't be longer than 25 chracters";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  /*
                  TextFormField(
                initialValue: "Name",
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onSaved: (deger) {
                  _name = deger!;
                },
                validator: (deger) {
                  if (deger!.isEmpty) {
                    return "Cannot be null";
                  } else if (deger.length < 3) {
                    return "Username cannot be small than 3 chracters";
                  } else {
                    // hata uretme
                    return null;
                  }
                },
              ),
              */
                ),
              ],
            ),
            // birth date
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.none,
                  decoration: const InputDecoration(
                    labelText: "Birthdate dd/mm/yyyy",
                    hintText: "",
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 8),
                      firstDate: DateTime(1900, 8),
                      lastDate: DateTime(2019, 8),
                    );
                  },
                  onSaved: (deger) {
                    _birthdate = DateTime.parse(deger!);
                    print(_birthdate);
                  },
                  validator: (deger) {
                    if (deger!.trim().isEmpty) {
                      return "Birthdate can't be empty";
                    } else if (DateTime.tryParse(deger) == null) {
                      return "Please select a valid date";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH);

                bool validate = formKey.currentState!.validate();
                if (validate) {
                  formKey.currentState!.save();
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Save'),
              backgroundColor: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
  var user = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  return user;
}

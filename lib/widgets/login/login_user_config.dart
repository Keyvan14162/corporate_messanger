import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_firebase_auth/helpers/login_helpers.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';

class LoginUserConfig extends StatefulWidget {
  const LoginUserConfig({Key? key}) : super(key: key);

  @override
  State<LoginUserConfig> createState() => _LoginUserConfigState();
}

class _LoginUserConfigState extends State<LoginUserConfig> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("-------------" + FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fill the fields"),
      ),
      body: Center(
        child: Form(
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
                    decoration: const InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/widgets/login/custom_gender_select.dart';
import 'package:flutter_firebase_auth/widgets/login/gender.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class UserUpdate extends StatefulWidget {
  const UserUpdate({Key? key}) : super(key: key);

  @override
  State<UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<UserUpdate> {
  final formKey = GlobalKey<FormState>();
  String _name = "name";
  DateTime _birthdate = DateTime(2000);
  final TextEditingController _textEditingController = TextEditingController();
  List<Gender> genders = <Gender>[];
  String _gender = "gender";
  int _age = 0;
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    genders.add(Gender("Male", Icons.male, false));
    genders.add(Gender("Female", Icons.female, false));
    genders.add(Gender("Don't wanna specify", Icons.ac_unit, false));
  }

  @override
  Widget build(BuildContext context) {
    print("--------------BUILD----------------");

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).primaryColor,
              )),
          title: Text(
            "Change User Informations",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // profile img
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                    child: StreamBuilder(
                      stream: getUserStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                MySnackbar.getGalleryCameraSnackbar(
                                    Theme.of(context).primaryColor, context),
                              );
                            },
                            child: CircleAvatar(
                              //  foregroundImage: ImageProvider(),
                              maxRadius: 80,
                              child: CircleAvatar(
                                radius: 144 / 2 + 10,
                                backgroundColor:
                                    Theme.of(context).secondaryHeaderColor,
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Text(
                      "Click profile image to change it",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  // name
                  StreamBuilder(
                    stream: getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: TextEditingController(
                              text: (snapshot.data as DocumentSnapshot)["name"],
                            ),
                            decoration: InputDecoration(
                              labelText:
                                  (snapshot.data as DocumentSnapshot)["name"],
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSaved: (deger) {
                              _name = deger!;
                            },
                            onChanged: (value) {
                              formKey.currentState!.validate();
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
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSaved: (deger) {
                              _name = deger!;
                            },
                            onChanged: (value) {
                              formKey.currentState!.validate();
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
                        );
                      }
                    },
                  ),

                  // birth date
                  StreamBuilder(
                    stream: getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _textEditingController.text =
                            (snapshot.data as DocumentSnapshot)["birthdate"];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _textEditingController,
                            keyboardType: TextInputType.none,
                            decoration: InputDecoration(
                              labelText: (snapshot.data
                                  as DocumentSnapshot)["birthdate"],
                              suffix: Text("Age : $_age"),
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onTap: () async {
                              await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000, 8),
                                firstDate: DateTime(1900, 8),
                                lastDate: DateTime.now(),
                              ).then((value) {
                                _birthdate = value!;
                                _textEditingController.text =
                                    _birthdate.toString().substring(0, 10);
                                formKey.currentState!.validate();
                                _age = AgeCalculator.age(_birthdate).years;
                                setState(() {});
                              });
                            },
                            onChanged: (value) {
                              formKey.currentState!.validate();
                            },
                            onSaved: (deger) {
                              _birthdate = DateTime.parse(deger!);
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
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _textEditingController,
                            keyboardType: TextInputType.none,
                            decoration: InputDecoration(
                              labelText: "Birthdate yyyy/mm/dd",
                              suffix: Text("Age : $_age"),
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onTap: () async {
                              await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000, 8),
                                firstDate: DateTime(1900, 8),
                                lastDate: DateTime.now(),
                              ).then((value) {
                                _birthdate = value!;
                                _textEditingController.text =
                                    _birthdate.toString().substring(0, 10);
                                formKey.currentState!.validate();
                                _age = AgeCalculator.age(_birthdate).years;
                                setState(() {});
                              });
                            },
                            onChanged: (value) {
                              formKey.currentState!.validate();
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
                        );
                      }
                    },
                  ),

                  // gender
                  StreamBuilder(
                    stream: getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String readedGender =
                            (snapshot.data as DocumentSnapshot)["gender"];
                        genders.forEach((element) {
                          if (element.name == readedGender && isFirst) {
                            element.isSelected = true;
                            _gender = element.name;
                            isFirst = false;
                          }
                        });
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < genders.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      genders.forEach(
                                        (gender) => gender.isSelected = false,
                                      );
                                      genders[i].isSelected = true;
                                      _gender = genders[i].name;
                                    },
                                  );
                                },
                                child: CustomGenderSelect(
                                  genders[i],
                                  cardColor: Theme.of(context).primaryColor,
                                ),
                              ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < genders.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      genders.forEach(
                                        (gender) => gender.isSelected = false,
                                      );
                                      genders[i].isSelected = true;
                                      _gender = genders[i].name;
                                    },
                                  );
                                },
                                child: CustomGenderSelect(
                                  genders[i],
                                  cardColor: Theme.of(context).primaryColor,
                                ),
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: () async {
                  // Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH);

                  bool validate = formKey.currentState!.validate();
                  if (validate) {
                    formKey.currentState!.save();

                    await userUpdateConfig(
                      _name,
                      _age,
                      _birthdate.toString().substring(0, 10),
                      _gender,
                    );
                    Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH);
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Save'),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future userUpdateConfig(
      String name, int age, String birthdate, String gender) async {
    await FirebaseFirestore.instance
        .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
        .update(
      {
        "name": name,
        "age": age,
        "birthdate": birthdate,
        "gender": gender,
      },
    );
  }
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
  var user = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  return user;
}

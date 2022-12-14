import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/models/user_model.dart';
import 'package:flutter_firebase_auth/widgets/login/custom_gender_select.dart';
import 'package:flutter_firebase_auth/widgets/login/gender.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class LoginUserConfig extends StatefulWidget {
  const LoginUserConfig({Key? key}) : super(key: key);

  @override
  State<LoginUserConfig> createState() => _LoginUserConfigState();
}

class _LoginUserConfigState extends State<LoginUserConfig> {
  final formKey = GlobalKey<FormState>();
  String _name = "";
  DateTime _birthdate = DateTime(2000);
  TextEditingController _textEditingController = TextEditingController();
  String dropdownValue = 'One';
  List<Gender> genders = <Gender>[];
  String _gender = "Male";
  int _age = 0;

  @override
  void initState() {
    super.initState();
    print("-------------" + FirebaseAuth.instance.currentUser!.uid);
    genders.add(Gender("Male", Icons.male, true));
    genders.add(Gender("Female", Icons.female, false));
    genders.add(Gender("Don't wanna specify", Icons.ac_unit, false));
  }

  @override
  Widget build(BuildContext context) {
    print("--------------BUILD----------------");

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          MySnackbar.getSnackbar("Cannot go  back on this step."),
        );

        return false;
      },
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Fill the fields",
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
                    Padding(
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
                    ),

                    // birth date
                    Padding(
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
                            //borderSide: BorderSide.none,
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
                    ),
                    // gender
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < genders.length; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                genders.forEach(
                                    (gender) => gender.isSelected = false);
                                genders[i].isSelected = true;
                                _gender = genders[i].name;
                              });
                            },
                            child: CustomGenderSelect(
                              genders[i],
                              cardColor: Theme.of(context).primaryColor,
                            ),
                          ),
                      ],
                    )
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
                  onPressed: () {
                    // Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH);

                    bool validate = formKey.currentState!.validate();
                    if (validate) {
                      formKey.currentState!.save();

                      saveConfiguredUserToFirestore(
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
      ),
    );
  }

  saveConfiguredUserToFirestore(
      String name, int age, String birthdate, String gender) async {
    var user = UserModel(
      name: name,
      age: age,
      friends: [],
      groups: [],
      birthdate: birthdate,
      gender: gender,
    );

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> eklenecekUser = <String, dynamic>{};
    eklenecekUser["name"] = user.name;
    eklenecekUser["age"] = user.age;
    eklenecekUser["createdAt"] = FieldValue.serverTimestamp();
    eklenecekUser["friends"] = user.friends;
    eklenecekUser["groups"] = user.groups;
    eklenecekUser["birthdate"] = user.birthdate;
    eklenecekUser["gender"] = user.gender;

    // kullaniciyi guncelleme
    await FirebaseFirestore.instance
        .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
        .set(
          eklenecekUser,
          SetOptions(merge: true),
        );

    // resim url ekleyelim
    /*
    var profileImgRef =
        FirebaseStorage.instance.ref().child("users/profilePics/profile.jpg");

    var coverImgRef =
        FirebaseStorage.instance.ref().child("users/coverPics/cover.jpg");
        

    await firestore.doc("users/${auth.currentUser!.uid}").update({
      "profileImg": await profileImgRef.getDownloadURL(),
      "coverImg": await coverImgRef.getDownloadURL()
    });
    */
  }
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
  var user = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  return user;
}

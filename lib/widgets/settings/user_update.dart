import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/settings_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class UserUpdate extends StatefulWidget {
  final String userId;
  const UserUpdate({required this.userId, Key? key}) : super(key: key);

  @override
  State<UserUpdate> createState() => _UserUpdateState();
}

String _name = "";
int _age = 0;

class _UserUpdateState extends State<UserUpdate> {
  // formumuzun stateine erissin, bunu formu keyine verip
  // formu butona basilinca kullanabiliriz
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Form Field"),
      ),
      // sigmazsa scroll olsun
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // form olmali
          child: Form(
            key: formKey,

            autovalidateMode: AutovalidateMode.always, // kontrol, validate
            // onUserInterraction focus oldugunda gosterir
            child: Column(
              children: [
                Text(widget.userId),
                // Name
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
                const SizedBox(
                  height: 20,
                ),
                // Age
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Age",
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (deger) {
                    _age = int.parse(deger!);
                  },
                  validator: (deger) {
                    if (deger!.isEmpty) {
                      return "Cannot be null";
                      // ignore: prefer_is_empty
                    } else if (deger.length < 0) {
                      return "Age cannot be small than 0";
                    } else {
                      return null;
                    }
                  },
                ),

                ElevatedButton(
                  onPressed: (() {
                    // formu validate et,
                    bool validate = formKey.currentState!.validate();
                    if (validate) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Uyarı"),
                          content: Text("Değişiklikler kaydedilsin mi ?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(Constants.SETTINGS_PATH);
                              },
                              child: const Text("Hayır"),
                            ),
                            TextButton(
                              onPressed: () {
                                // on save metodlari calisir
                                formKey.currentState!.save();
                                updateUser(_name, _age, widget.userId);

                                // savelendikten sonra reset, initial value verdiklerin
                                // resetlenmez
                                formKey.currentState!.reset();
                                Navigator.of(context)
                                    .pushNamed(Constants.SETTINGS_PATH);
                              },
                              child: const Text("Evet"),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  final formKey = GlobalKey<FormState>();

  String _yeniSifre = "";
  String _yeniSifreTekrar = "";

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
                      labelText: "New password",
                      hintText: "New password",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (deger) {
                      _yeniSifre = deger!;
                    },
                    validator: (deger) {
                      if (deger!.length < 5) {
                        return "Password can't be smaller than 5 chracters";
                      } else {
                        return null;
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // yeni sifre tekrar
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "New password again",
                      hintText: "New password again",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (deger) {
                      _yeniSifreTekrar = deger!;
                    },
                    validator: (deger) {
                      // email var ise true don
                      if (deger!.length < 5) {
                        return "Password can't be smaller than 5 chracters";
                      } else {
                        return null;
                      }
                    },
                  ),

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

                      if (validate &&
                          (_yeniSifre.trim() == _yeniSifreTekrar.trim())) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Alert"),
                            content: Text(
                                "Are you sure taht you want to change your password?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(Constants.SETTINGS_PATH);
                                  },
                                  child: const Text("No")),
                              TextButton(
                                onPressed: () {
                                  changePassword(_yeniSifre);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      MySnackbar.getSnackbar(
                                          "New password : $_yeniSifre"));
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

  void changePassword(String yeniSifre) async {
    // auth uzerinden current user'a eriselim.
    try {
      await widget.auth.currentUser!.updatePassword(yeniSifre);
      await widget.auth.signOut();
      // showMessage("İlk try Yeni sifrenizle giris yapabilirsiniz");
      Navigator.of(context).pop();
      // hassas islem, firebase bidaha oturum ac once diyo
      // hata fırlatıyo bunun icin
      // bende olmadı tabı
    } on FirebaseAuthException catch (e) {
      // yada burda kullanıcıyı cıkar tekrar giris yapsın
      if (e.code == "requires-recent-login") {
        // eski email_sifre_girisde aldıgımız email sifre, tekrar giris yapmış gibi
        var credietial = EmailAuthProvider.credential(
            // KULLANICI EPOSTA VEYA SIFRE DEGISTIRDIYSE PATLIYO BURASI
            // KULLANICIDAN EMAIL VE ESKI SIFRESINI DE ISTEYEBILIN ONCE
            email: "email",
            password: "new_pass");
        await widget.auth.currentUser!.reauthenticateWithCredential(credietial);
        await widget.auth.currentUser!.updatePassword(_yeniSifre);
        await widget.auth.signOut();
        // showMessage("Yeni sifrenizle giris yapabilirsiniz");
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

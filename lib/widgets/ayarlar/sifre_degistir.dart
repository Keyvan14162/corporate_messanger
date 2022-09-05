import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SifreDegistir extends StatefulWidget {
  SifreDegistir({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  State<SifreDegistir> createState() => _SifreDegistirState();
}

class _SifreDegistirState extends State<SifreDegistir> {
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
                      labelText: "Yeni sifre",
                      hintText: "Yeni sifre",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (deger) {
                      _yeniSifre = deger!;
                    },
                    validator: (deger) {
                      if (deger!.length < 5) {
                        return "Sifre 5 karakterdne kucuk olamaz";
                      } else {
                        return null;
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // yeni sifre tekrar
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Yeni sifre tekrar",
                      hintText: "Yeni sifre tekrar",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (deger) {
                      _yeniSifreTekrar = deger!;
                    },
                    validator: (deger) {
                      // email var ise true don
                      if (deger!.length < 5) {
                        return "Sifre 5 karakterdne kucuk olamaz";
                      } else {
                        return null;
                      }
                    },
                  ),

                  // degistir buton
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(10),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () async {
                      bool validate = formKey.currentState!.validate();
                      formKey.currentState!.save();

                      if (validate &&
                          (_yeniSifre.trim() == _yeniSifreTekrar.trim())) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Uyarı"),
                            content: Text(
                                "Şifrenizi değiştirmek istediğinizden emin misiniz ?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed("/ayarlar");
                                  },
                                  child: const Text("Hayır")),
                              TextButton(
                                  onPressed: () {
                                    changePassword(_yeniSifre);
                                    showMessage("yeni sifre : $_yeniSifre");
                                    Navigator.of(context).pushNamed("/ayarlar");
                                  },
                                  child: const Text("Evet")),
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
                          "Degistir",
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
      showMessage("İlk try Yeni sifrenizle giris yapabilirsiniz");
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
            email: "ismailkyvsn2000@gmail.com",
            password: "kamilkoc14162");
        await widget.auth.currentUser!.reauthenticateWithCredential(credietial);
        await widget.auth.currentUser!.updatePassword(_yeniSifre);
        await widget.auth.signOut();
        showMessage("Yeni sifrenizle giris yapabilirsiniz");
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(fontSize: 20)),
      backgroundColor: Colors.black,
    ));
  }
}

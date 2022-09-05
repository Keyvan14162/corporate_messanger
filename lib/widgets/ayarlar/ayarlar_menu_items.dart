import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AyarlarMenuItems extends StatefulWidget {
  const AyarlarMenuItems({Key? key}) : super(key: key);

  @override
  State<AyarlarMenuItems> createState() => _AyarlarMenuItemsState();
}

class _AyarlarMenuItemsState extends State<AyarlarMenuItems> {
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
          Navigator.of(context).pushNamed("/kullaniciGuncelle",
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
                    showMessage("${auth.currentUser!.email} çıkış yaptı");
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
                    var sonuc = await deleteUser();
                    if (sonuc) {
                      Navigator.of(context).pop();
                      showMessage("silindi");
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
          hesapDogrula();
        }),

        // Password Change 141622
        createButton("Sifre degistir", Icons.password, () async {
          Navigator.of(context).pushNamed("/sifreDegistir", arguments: auth);
        }),

        // Mail Change
        createButton("Mail Değiştir", Icons.mail, () async {
          Navigator.of(context).pushNamed("/mailDegistir", arguments: auth);
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

  void hesapDogrula() async {
    // hesabı dogrulayınca anlamıyo tekra giriş yapınca oluyo****
    if (auth.currentUser != null) {
      if (auth.currentUser!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${auth.currentUser!.email} hesabı dogrulanmıstır  ",
              style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.black,
        ));
      } else {
        try {
          await auth.currentUser!.sendEmailVerification();

          showMessage(
              "Mailinize gonderilen linke tıklayarak hesabınızı dogrulaynız. Hesabın dogrulandıgını gormke icin uygulamaya tekrar giris yapınız");
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString(), style: const TextStyle(fontSize: 20)),
            backgroundColor: Colors.black,
          ));
          await auth.signOut();

          Navigator.of(context).pop();
        }
      }
    }

    setState(() {});
  }

  void signOutUser() async {
    // current userdan cikis yapar,
    // email_sifre_giris initstatedeki authstatelisten calisir
    // firebase kısmından cıkıs yapar

    await auth.signOut();

    // google ile giris yapildiysa cıkıs yapar, yoksa googledan cikmaz
    // bu syaede eposta sifre ile girerse googledan cıkmaya calısmaz
    var user = GoogleSignIn().currentUser;
    if (user != null) {
      await GoogleSignIn().signOut();
    }
  }

  Future<bool> deleteUser() async {
    // bu sayfaya geldiyse zaten oturm acmis olcak da olsun
    // kontrol edelim
    // google ile giriis icin degistirmedi calisiyo galiba

    // kullanici hesabi silse de attiği ve aldiği mesajlari silmiyom

    if (auth.currentUser != null) {
      var uid = auth.currentUser!.uid;
      try {
        // databaseden de silsin

        await auth.currentUser!.delete();

        await FirebaseFirestore.instance.doc("users/$uid").delete();

        // storageden silsin
        final coverImgRef =
            FirebaseStorage.instance.ref().child("users/coverPics/$uid");
        await coverImgRef.delete();

        final profileImgRef =
            FirebaseStorage.instance.ref().child("users/profilePics/$uid");
        await profileImgRef.delete();

        Navigator.of(context).pushNamed("/girisEkrani");

        return true;
      } catch (e) {
        // requires login again
        showMessage(
            "Bu kritik bir işlemdir, silmek icin hesabınıza tekrar giris yapınız.");
      }
    } else if (auth.currentUser == null) {
      print("Once oturum ac");
      return false;
    }
    return false;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(fontSize: 20)),
      backgroundColor: Colors.black,
    ));
  }

// BUNU KULLANIRSAN HER FONKTA AYNI ISI YAPMALISIN
// TEK TEK USTTE TANIMLICAN ARTIK
  void showMyAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () {}, child: const Text("data")),
          TextButton(onPressed: () {}, child: const Text("data")),
        ],
      ),
    );
  }
}

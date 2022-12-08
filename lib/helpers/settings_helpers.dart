import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/models/user_model.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

void hesapDogrula(BuildContext context) async {
  // hesabı dogrulayınca anlamıyo tekra giriş yapınca oluyo****
  if (FirebaseAuth.instance.currentUser != null) {
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackbar.getSnackbar(
            "${FirebaseAuth.instance.currentUser!.email} account verified."),
      );
    } else {
      try {
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          MySnackbar.getSnackbar(
              "Verify your account by clicking the link sent to your e-mail. Login to the application again to see that the account has been verified."),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(MySnackbar.getSnackbar(e.toString()));
        await FirebaseAuth.instance.signOut();

        Navigator.of(context).pop();
      }
    }
  }
}

void signOutUser() async {
  // current userdan cikis yapar,
  // email_sifre_giris initstatedeki authstatelisten calisir
  // firebase kısmından cıkıs yapar

  await FirebaseAuth.instance.signOut();

  // google ile giris yapildiysa cıkıs yapar, yoksa googledan cikmaz
  // bu syaede eposta sifre ile girerse googledan cıkmaya calısmaz
  var user = GoogleSignIn().currentUser;
  if (user != null) {
    await GoogleSignIn().signOut();
  }
}

Future<bool> deleteUser(BuildContext context) async {
  // bu sayfaya geldiyse zaten oturm acmis olcak da olsun
  // kontrol edelim
  // google ile giriis icin degistirmedi calisiyo galiba

  // kullanici hesabi silse de attiği ve aldiği mesajlari silmiyom

  if (FirebaseAuth.instance.currentUser != null) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      // databaseden de silsin

      await FirebaseAuth.instance.currentUser!.delete();

      await FirebaseFirestore.instance.doc("users/$uid").delete();

      // storageden silsin
      final coverImgRef =
          FirebaseStorage.instance.ref().child("users/coverPics/$uid");
      await coverImgRef.delete();

      final profileImgRef =
          FirebaseStorage.instance.ref().child("users/profilePics/$uid");
      await profileImgRef.delete();

      Navigator.of(context).pushNamed(Constants.LOGIN_SCREEN_PATH);

      return true;
    } catch (e) {
      // requires login again

      ScaffoldMessenger.of(context).showSnackBar(
        MySnackbar.getSnackbar(
            "This is a critical operation, please login to your account again to delete it."),
      );
    }
  } else if (FirebaseAuth.instance.currentUser == null) {
    // oturum açmadan buraya geldiyse zaten sıkıntı buyuk
    ScaffoldMessenger.of(context).showSnackBar(
      MySnackbar.getSnackbar(
          "You are logged in, close the application and try again"),
    );
    return false;
  }
  return false;
}

Future updateUser(String name, int age, String userId) async {
  var user =
      // profile pic url
      UserModel(
    name: name,
    age: age,
    friends: [],
    groups: [],
    birthdate: "",
    gender: "",
  );

  Map<String, dynamic> eklenecekUser = <String, dynamic>{};
  eklenecekUser["name"] = user.name;
  eklenecekUser["age"] = user.age;
  eklenecekUser["createdAt"] = FieldValue.serverTimestamp();
  // sifirlamasin
  // eklenecekUser["friends"] = user.friends;

  // kullaniciyi guncelleme
  await FirebaseFirestore.instance.doc("users/${userId}").set(
        eklenecekUser,
        SetOptions(merge: true),
      );
}

void changeMail(
    String yeniMail, FirebaseAuth auth, BuildContext context) async {
  // auth uzerinden current user'a eriselim.
  try {
    await auth.currentUser!.updateEmail(yeniMail);
    await auth.signOut();
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      MySnackbar.getSnackbar("İlk try You can login with your new e-mail."),
    );
    */
    Navigator.of(context).pushNamed(Constants.LOGIN_SCREEN_PATH);
    // hassas islem, firebase bidaha oturum ac once diyo
    // hata fırlatıyo bunun icin
    // bende olmadı tabı
  } on FirebaseAuthException catch (e) {
    if (e.code == "requires-recent-login") {
      // eski email_sifre_girisde aldıgımız email sifre, tekrar giris yapmış gibi
      var credietial = EmailAuthProvider.credential(
          email: "ismailkyvsn2000@gmail.com", password: "123456789");
      await auth.currentUser!.reauthenticateWithCredential(credietial);
      await auth.currentUser!.updateEmail(yeniMail);
      await auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackbar.getSnackbar("You can login with your new e-mail."),
      );
      Navigator.of(context).pushNamed(Constants.LOGIN_CONTROL_PATH);
    }
  } catch (e) {
    print(e.toString());
  }
}

changeProfileImgGallery(BuildContext context, String userId) async {
  // firestore'a id ile isimlendirip resmi atsın
  // firebase de userin profileImg download urlsini degistrisin
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Warning"),
        content: const Text("Change profile picture ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              // image quality max 100
              XFile? file = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 25);

              var profileRef =
                  FirebaseStorage.instance.ref("users/profilePics/${userId}");

              var task = profileRef.putFile(File(file!.path));

              task.whenComplete(() async {
                var url = await profileRef.getDownloadURL();
                // dbye url yi yazdircaz

                FirebaseFirestore.instance
                    .doc("users/${userId}")
                    .update({"profileImg": url.toString()});
              });
              Navigator.of(context).pushNamed(Constants.HOME_PAGE_PATH);
            },
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );
}

changeCoverImgGallery(String userId) async {
  try {
    // firestore'a id ile isimlendirip resmi atsın
    // firebase de userin profileImg download urlsini degistrisin
    final ImagePicker picker = ImagePicker();
    // image quality max 100
    XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    var profileRef = FirebaseStorage.instance.ref("users/coverPics/${userId}");

    var task = profileRef.putFile(File(file!.path));

    task.whenComplete(() async {
      var url = await profileRef.getDownloadURL();
      // dbye url yi yazdircaz

      FirebaseFirestore.instance
          .doc("users/${userId}")
          .update({"coverImg": url.toString()});
    });
  } catch (e) {}
}

// user fieldalrinda kayitli olan coverImg ve profileImg aliyor
Future<String> getDownloadUrl(String userId, String img) async {
  // one time read
  var url = (await FirebaseFirestore.instance.doc("users/${userId}").get())
      .data()![img];

  return url;
}

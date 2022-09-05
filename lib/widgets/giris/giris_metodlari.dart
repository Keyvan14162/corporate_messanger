import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/model/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GirisMetodlari {
  void saveUserToFirestore(String name, int age, String userId) async {
    var user =
        // profile pic url
        UserModel(name: name, age: age, friends: []);

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> eklenecekUser = <String, dynamic>{};
    eklenecekUser["name"] = user.name;
    eklenecekUser["age"] = user.age;
    eklenecekUser["createdAt"] = FieldValue.serverTimestamp();

    // kullaniciyi guncelleme
    await FirebaseFirestore.instance.doc("users/$userId").set(
          eklenecekUser,
          SetOptions(merge: true),
        );

    // default resimleri ekle
    var profileImgRef =
        FirebaseStorage.instance.ref("users/profilePics/$userId");

    var coverImgRef = FirebaseStorage.instance.ref("users/coverPics/$userId");

    await firestore.doc("users/$userId").update({
      "profileImg": await profileImgRef.getDownloadURL(),
      "coverImg": await coverImgRef.getDownloadURL()
    });
  }

  Future createEmailAndPass(FirebaseAuth auth, String email, String pass,
      BuildContext context) async {
    // tryi ustte butona basilinca da yapabilin
    try {
      // user lan bu
      var userCrediantal = await auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      var user = userCrediantal.user;

      // HESAP DOGRULAMA MAİN_PAGE'DE

      _showMessage("Kayıt Olundu", email, pass, context);
    } catch (e) {
      // create.. ozelliklerine bak, invalid email vs. firlatabilir
      // print(e.toString());
      _showMessage(e.toString(), email, pass, context);
    }
  }

  Future<User?> loginEmailAndPass(FirebaseAuth auth, String email, String pass,
      BuildContext context) async {
    // tryi ustte butona basilinca da yapabilin
    try {
      var userCrediantal =
          await auth.signInWithEmailAndPassword(email: email, password: pass);
      var user = userCrediantal.user;

      // print(_user.toString());
      // true donebilir mesela
      // _showMessage("Giriş Yapıldı");
      return user;
    } catch (e) {
      // print(e.toString());
      _showMessage(e.toString(), email, pass, context);
    }
    return null;
  }

  Future<UserCredential> googleileGiris() async {
    // siteden caldim
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // hoca return kullanmadi
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

// authu glabal tutmalıyız
// provider kullanılabilir
  void firebaseUserConfig(FirebaseAuth auth) async {
    try {
      // burasi 2. defa girdiginde fln
      // name cekerse onceden girmis demek, girmisse bisi yapma
      // girmemisse name, age, resim alanlarını fln ekle
      var userName = (await FirebaseFirestore.instance
              .doc("users/${auth.currentUser!.uid}")
              .get())
          .data()!["name"];
    } catch (e) {
      // yani boyle bi user yoksa, ilk kaytsa firebasede defaukt bi user olustursun
      var user =
          // profile pic url
          UserModel(name: "Name", age: 0, friends: []);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> eklenecekUser = <String, dynamic>{};
      eklenecekUser["name"] = user.name;
      eklenecekUser["age"] = user.age;
      eklenecekUser["createdAt"] = FieldValue.serverTimestamp();

      // kullaniciyi guncelleme
      await FirebaseFirestore.instance
          .doc("users/${auth.currentUser!.uid}")
          .set(
            eklenecekUser,
            SetOptions(merge: true),
          );

      // resim url ekleyelim

      var profileImgRef =
          FirebaseStorage.instance.ref().child("users/profilePics/profile.jpg");

      var coverImgRef =
          FirebaseStorage.instance.ref().child("users/coverPics/cover.jpg");

      await firestore.doc("users/${auth.currentUser!.uid}").update({
        "profileImg": await profileImgRef.getDownloadURL(),
        "coverImg": await coverImgRef.getDownloadURL()
      });
    }
  }

  void _showMessage(
      String durum, String email, String pass, BuildContext context) {
    String result = "email: $email \n password: $pass\n  $durum";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result, style: const TextStyle(fontSize: 20)),
        backgroundColor: Colors.black,
      ),
    );
  }
}

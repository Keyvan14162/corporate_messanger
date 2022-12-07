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

void saveUserToFirestore(String name, int age, String userId) async {
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

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> eklenecekUser = <String, dynamic>{};
  eklenecekUser["name"] = user.name;
  eklenecekUser["age"] = user.age;
  eklenecekUser["createdAt"] = FieldValue.serverTimestamp();
  // eklenecekUser["friends"] = user.friends;

  // kullaniciyi guncelleme
  await FirebaseFirestore.instance.doc("users/$userId").set(
        eklenecekUser,
        SetOptions(merge: true),
      );

  // default resimleri ekle
  var profileImgRef = FirebaseStorage.instance.ref("users/profilePics/$userId");

  var coverImgRef = FirebaseStorage.instance.ref("users/coverPics/$userId");

  await firestore.doc("users/$userId").update({
    "profileImg": await profileImgRef.getDownloadURL(),
    "coverImg": await coverImgRef.getDownloadURL()
  });
}

Future createEmailAndPass(FirebaseAuth auth, String email, String pass) async {
  // tryi ustte butona basilinca da yapabilin
  try {
    // user lan bu
    var userCrediantal = await auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    var user = userCrediantal.user;

    // HESAP DOGRULAMA MAİN_PAGE'DE
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      MySnackbar.getSnackbar("Email: $email \n Şifre: $pass\n  Kayıt olundu."),
    );
    */
  } catch (e) {
    // create.. ozelliklerine bak, invalid email vs. firlatabilir
    // print(e.toString());
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      MySnackbar.getSnackbar(
          "Email: $email \n Şifre: $pass\n  ${e.toString()}."),
    );
    */
  }
}

Future<User?> loginEmailAndPass(
    FirebaseAuth auth, String email, String pass, BuildContext context) async {
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
    ScaffoldMessenger.of(context).showSnackBar(MySnackbar.getSnackbar(
        "E-mail: $email \n Password: $pass\n  ${e.toString()}."));
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
Future firebaseUserConfig(FirebaseAuth auth, BuildContext context) async {
  try {
    // burasi 2. defa girdiginde fln
    // name cekerse onceden girmis demek, girmisse bisi yapma
    // girmemisse name, age, resim alanlarını fln ekle
    var userName = (await FirebaseFirestore.instance
            .doc("users/${auth.currentUser!.uid}")
            .get())
        .data()!["name"];
  } catch (e) {
    // yani boyle bi user yoksa, ilk kaytsa firebasede default bi user olustursun

    var user = UserModel(
      name: "Name",
      age: 0,
      friends: [],
      groups: [],
      birthdate: "",
      gender: "",
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

    var profileImgRef =
        FirebaseStorage.instance.ref().child("users/profilePics/profile.jpg");

    var coverImgRef =
        FirebaseStorage.instance.ref().child("users/coverPics/cover.jpg");

    await firestore.doc("users/${auth.currentUser!.uid}").update({
      "profileImg": await profileImgRef.getDownloadURL(),
      "coverImg": await coverImgRef.getDownloadURL()
    });

    // Kullanicilardan bilgiler istensin
    Navigator.of(context).pushNamed(Constants.LOGIN_USER_CONFIG_PATH);
  }
}

chooseProfileImg(String userId, ImageSource source) async {
  // firestore'a id ile isimlendirip resmi atsın
  // firebase de userin profileImg download urlsini degistrisin
  final ImagePicker picker = ImagePicker();
  // image quality max 100
  XFile? file = await picker.pickImage(source: source, imageQuality: 25);

  var profileRef = FirebaseStorage.instance.ref("users/profilePics/${userId}");

  var task = profileRef.putFile(File(file!.path));

  task.whenComplete(() async {
    var url = await profileRef.getDownloadURL();
    // dbye url yi yazdircaz

    FirebaseFirestore.instance
        .doc("users/${userId}")
        .update({"profileImg": url.toString()});
  });
}

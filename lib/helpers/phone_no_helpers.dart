import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/login_helpers.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';

void telNoGiris(String telNo, BuildContext context) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: telNo,
    // default 30 sn bekle, cihaz kod gelsin de isleyim diye bekliyo
    timeout: const Duration(seconds: 60),
    // forceResendingToken: , kod gelmediyse bida yolla
    // islem tamam
    verificationCompleted: (PhoneAuthCredential credential) async {
      // firebase'e giris
      await FirebaseAuth.instance.signInWithCredential(credential);

      // .currentuser.auth?
      firebaseUserConfig(FirebaseAuth.instance, context);

      ScaffoldMessenger.of(context)
          .showSnackBar(MySnackbar.getSnackbar("Doğrulama tamamlandı."));
    },
    // hata
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        ScaffoldMessenger.of(context).showSnackBar(
            MySnackbar.getSnackbar("Girilen numara uygun değil."));
      }
    },
    // kullaniciya 6 karakterli numara yollaniyo, burda o kodu iste
    // bunu biz ayarliyoz heralde random code sec fln burda 111111 yollicam hep
    codeSent: (String verificationId, int? resendToken) async {
      try {
        // ui ile kulanicidan girilen kodu al, bu kullanicin girdigi kod
        String smsCode = "";

        ScaffoldMessenger.of(context).showSnackBar(MySnackbar.getSnackbar(
            "Lütfen numaranıza gönderilen kodu giriniz."));

        await Navigator.of(context).pushNamed("/telNoDogrulama").then((value) {
          smsCode = value as String;
        });

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        ScaffoldMessenger.of(context).showSnackBar(MySnackbar.getSnackbar(
            "${FirebaseAuth.instance.currentUser!.phoneNumber} kayıt oldu."));

        firebaseUserConfig(FirebaseAuth.instance, context);

        Navigator.of(context).pushNamed("/anaSayfa");
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(MySnackbar.getSnackbar(e.toString()));
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) async {},
  );
}

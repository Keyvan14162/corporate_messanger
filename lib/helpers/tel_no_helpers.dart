import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/giris_helpers.dart';

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

      firebaseUserConfig(FirebaseAuth.instance);

      showMessageTelNo(
          "verificationCompleted tetiklendi ${credential.toString()},",
          context);
    },
    // hata
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        showMessageTelNo("The provided phone number is not valid.", context);
      }
    },
    // kullaniciya 6 karakterli numara yollaniyo, burda o kodu iste
    // bunu biz ayarliyoz heralde random code sec fln burda 111111 yollicam hep
    codeSent: (String verificationId, int? resendToken) async {
      try {
        // ui ile kulanicidan girilen kodu al, bu kullanicin girdigi kod
        String smsCode = "";

        showMessageTelNo("Lutfen numaranıza gönderilen kodu giriniz", context);

        await Navigator.of(context).pushNamed("/telNoDogrulama").then((value) {
          smsCode = value as String;
        });

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        showMessageTelNo(
            "${FirebaseAuth.instance.currentUser!.phoneNumber} kayit oldu ",
            context);

        firebaseUserConfig(FirebaseAuth.instance);

        Navigator.of(context).pushNamed("/anaSayfa");
      } catch (e) {
        showMessageTelNo(e.toString(), context);
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) async {},
  );
}

void showMessageTelNo(String mesaj, BuildContext context) {
  String result = " $mesaj";
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(result, style: TextStyle(fontSize: 20)),
    backgroundColor: Colors.black,
  ));
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/helpers/giris_helpers.dart';
/*
void telNoGiris(String telNo) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: telNo,
    // default 30 sn bekle, cihaz kod gelsin de isleyim diye bekliyo
    timeout: const Duration(seconds: 60),
    // forceResendingToken: , kod gelmediyse bida yolla
    // islem tamam
    verificationCompleted: (PhoneAuthCredential credential) async {
      // firebase'e giris
      await FirebaseAuth.instance.signInWithCredential(credential);

      firebaseUserConfig(auth);

      _showMessage("verificationCompleted tetiklendi ${credential.toString()}");
    },
    // hata
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        _showMessage("The provided phone number is not valid.");
      }
    },
    // kullaniciya 6 karakterli numara yollaniyo, burda o kodu iste
    // bunu biz ayarliyoz heralde random code sec fln burda 111111 yollicam hep
    codeSent: (String verificationId, int? resendToken) async {
      try {
        // ui ile kulanicidan girilen kodu al, bu kullanicin girdigi kod
        String smsCode = "";

        _showMessage("Lutfen numaranıza gönderilen kodu giriniz");

        await Navigator.of(context).pushNamed("/telNoDogrulama").then((value) {
          smsCode = value as String;
        });

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        await auth.signInWithCredential(credential);

        _showMessage("${auth.currentUser!.phoneNumber} kayit oldu ");

        firebaseUserConfig(auth);

        Navigator.of(context).pushNamed("/anaSayfa");
      } catch (e) {
        _showMessage(e.toString());
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) async {},
  );
}
*/

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/giris_helpers.dart';
import 'package:flutter_firebase_auth/helpers/tel_no_helpers.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class TelefonNumarasiGiris extends StatefulWidget {
  const TelefonNumarasiGiris({Key? key}) : super(key: key);

  @override
  State<TelefonNumarasiGiris> createState() => _TelefonNumarasiGirisState();
}

class _TelefonNumarasiGirisState extends State<TelefonNumarasiGiris> {
  final formKey = GlobalKey<FormState>();
  String telNo = "";

  late Timer _timer;
  int _start = 60;

  // ikisi de ayni deger icin, ama usttekinde kontrol ediyoz
  // 6 karakterse ve butona basılmıssa alttakine atiyoz
  String userVerificationCode = "";
  String smsCode = "";

  bool verificationCodeEnterEnabed = false;

  late FirebaseAuth auth;
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telefon Numarasi ile Giriş"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // intl_phone_field paketi
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                  initialCountryCode: 'TR',
                  onChanged: (phone) {
                    telNo = phone.countryCode + phone.number;
                  },
                ),

                // Dogrulama kodu yolla
                ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all<double>(10),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.cyan),
                  ),
                  onPressed: () {
                    if (telNo.toString().length == 13) {
                      telNoGiris(telNo);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.login, color: Colors.white),
                      Text(
                        "Doğrulama Kodu Gönder",
                        maxLines: 1,
                        style: TextStyle(color: Colors.white),
                      ),
                      // text ortalansin diye
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void telNoGiris(String telNo) async {
    await auth.verifyPhoneNumber(
      phoneNumber: telNo,
      // default 30 sn bekle, cihaz kod gelsin de isleyim diye bekliyo
      timeout: const Duration(seconds: 60),
      // forceResendingToken: , kod gelmediyse bida yolla
      // islem tamam
      verificationCompleted: (PhoneAuthCredential credential) async {
        // firebase'e giris
        await auth.signInWithCredential(credential);

        firebaseUserConfig(auth);

        showMessageTelNo(
            "verificationCompleted tetiklendi ${credential.toString()}",
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

          showMessageTelNo(
              "Lutfen numaranıza gönderilen kodu giriniz", context);

          await Navigator.of(context)
              .pushNamed("/telNoDogrulama")
              .then((value) {
            smsCode = value as String;
          });

          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await auth.signInWithCredential(credential);

          showMessageTelNo(
              "${auth.currentUser!.phoneNumber} kayit oldu ", context);

          firebaseUserConfig(auth);

          Navigator.of(context).pushNamed("/anaSayfa");
        } catch (e) {
          showMessageTelNo(e.toString(), context);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) async {},
    );
  }
}

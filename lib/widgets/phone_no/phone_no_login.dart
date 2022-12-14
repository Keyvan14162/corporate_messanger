import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/login_helpers.dart';
import 'package:flutter_firebase_auth/widgets/my_snackbar.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;

class PhoneNoLogin extends StatefulWidget {
  const PhoneNoLogin({Key? key}) : super(key: key);

  @override
  State<PhoneNoLogin> createState() => _PhoneNoLoginState();
}

class _PhoneNoLoginState extends State<PhoneNoLogin> {
  final formKey = GlobalKey<FormState>();
  String telNo = "";

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
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          "Phone Number Login ",
        ),
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
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                  ),
                  onPressed: () async {
                    if (telNo.toString().length == 13) {
                      await telNoGiris(telNo);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.login, color: Colors.white),
                      Text(
                        "Send Verification Code",
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

  Future telNoGiris(String telNo) async {
    await auth.verifyPhoneNumber(
      phoneNumber: telNo,
      // default 30 sn bekle, cihaz kod gelsin de isleyim diye bekliyo
      timeout: const Duration(seconds: 120),
      // forceResendingToken: , kod gelmediyse bida yolla
      // islem tamam
      verificationCompleted: (PhoneAuthCredential credential) async {
        // firebase'e giris
        await auth.signInWithCredential(credential);

        await firebaseUserConfig(auth, context);

        ScaffoldMessenger.of(context).showSnackBar(
          MySnackbar.getSnackbar("Verification complated."),
        );

        // Navigator.of(context).pushNamed(Constants.LOGIN_USER_CONFIG_PATH);
      },
      // hata
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context)
              .showSnackBar(MySnackbar.getSnackbar("Number is not valid"));
        }
      },
      // kullaniciya 6 karakterli numara yollaniyo, burda o kodu iste
      // bunu biz ayarliyoz heralde random code sec fln burda 111111 yollicam hep
      codeSent: (String verificationId, int? resendToken) async {
        try {
          // ui ile kulanicidan girilen kodu al, bu kullanicin girdigi kod
          String smsCode = "";

          ScaffoldMessenger.of(context).showSnackBar(
              MySnackbar.getSnackbar("Please enter verification code"));

          await Navigator.of(context)
              .pushNamed(Constants.PHONE_NO_VERIFICATION_PATH)
              .then((value) {
            smsCode = value as String;
          });

          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await auth.signInWithCredential(credential);

          ScaffoldMessenger.of(context).showSnackBar(MySnackbar.getSnackbar(
              "${auth.currentUser!.phoneNumber} entered."));

          firebaseUserConfig(auth, context);

          // Navigator.of(context).pushNamed(Constants.LOGIN_USER_CONFIG_PATH);
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(MySnackbar.getSnackbar(e.toString()));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) async {},
    );
  }
}

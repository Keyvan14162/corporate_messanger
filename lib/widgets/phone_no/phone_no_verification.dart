import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PhoneNoVerification extends StatefulWidget {
  const PhoneNoVerification({Key? key}) : super(key: key);

  @override
  State<PhoneNoVerification> createState() => _PhoneNoVerificationState();
}

class _PhoneNoVerificationState extends State<PhoneNoVerification> {
  final formKey = GlobalKey<FormState>();
  String smsCode = "";
  bool isSendCodeBackActive = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, smsCode);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Enter Verification Code "),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // yollan kodu gir
                    Pinput(
                      length: 6,
                      onChanged: (number) {
                        smsCode = number;
                        formKey.currentState!.validate();
                      },
                      onSubmitted: (value) {
                        smsCode = value;
                      },
                      validator: (number) {
                        if (number!.length < 6) {
                          return "Must be 6 chracters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // Kodu onayla
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(10),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        if (smsCode.toString().length == 6) {
                          Navigator.of(context).pop(smsCode);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.login, color: Colors.white),
                          Text(
                            "Verify Code",
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
      ),
    );
  }
}

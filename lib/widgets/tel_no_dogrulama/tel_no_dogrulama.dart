import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pinput/pinput.dart';

class TelNoDogrulama extends StatefulWidget {
  const TelNoDogrulama({Key? key}) : super(key: key);

  @override
  State<TelNoDogrulama> createState() => _TelNoDogrulamaState();
}

class _TelNoDogrulamaState extends State<TelNoDogrulama> {
  final formKey = GlobalKey<FormState>();
  String smsCode = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, smsCode);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Doğrulama Kodunu Giriniz"),
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
                    /*
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Verification Code ",
                        hintText: "_ _ _ _ _ _",
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 6,
                      onChanged: (number) {
                        smsCode = number;
                        formKey.currentState!.validate();
                      },
                      validator: (number) {
                        if (number!.length < 6) {
                          return "Must be 6 chracters";
                        }
                        return null;
                      },
                    ),*/

                    const SizedBox(
                      height: 30,
                    ),

                    // Kodu onayla
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(10),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.cyan),
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
                            "Kodu onayla",
                            maxLines: 1,
                            style: TextStyle(color: Colors.white),
                          ),
                          // text ortalansin diye
                          SizedBox(width: 10),
                        ],
                      ),
                    ),

                    // Kodu tekrar gonder
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(10),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.cyan),
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
                            "Kodu Tekrar Gönder ",
                            maxLines: 1,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text("12"),
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

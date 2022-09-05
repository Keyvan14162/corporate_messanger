import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Firebase Auth"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // firebase auth islemleri
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/girisKontrol");
                },
                child: const Text("Giris"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/telNoDogrulama");
                },
                child: const Text("Telefon pin dogurlama"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/ayarlar.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/kullanici_guncelle.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/mail_degistir.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/sifre_degistir.dart';
import 'package:flutter_firebase_auth/chat/chat_room.dart';
import 'package:flutter_firebase_auth/widgets/giris/giris_ekrani.dart';
import 'package:flutter_firebase_auth/main_page.dart';
import 'package:flutter_firebase_auth/widgets/giris/giris_kontrol.dart';
import 'package:flutter_firebase_auth/widgets/ana_sayfa.dart';
import 'package:flutter_firebase_auth/chat/personal_chat.dart';
import 'package:flutter_firebase_auth/chat/search_page.dart';
import 'package:flutter_firebase_auth/widgets/tel_no_dogrulama/tel_no_dogrulama.dart';
import 'package:flutter_firebase_auth/widgets/tel_no_dogrulama/tel_no_giris.dart';

class RouteGenerator {
  static Route<dynamic>? _generateRoute(
      Widget gidilecekPage, RouteSettings settings) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return MaterialPageRoute(
          builder: (context) => gidilecekPage, settings: settings);
    } else {
      return CupertinoPageRoute(
          builder: (context) => gidilecekPage, settings: settings);
    }
  }

  static Route<dynamic>? routeGenrator(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return _generateRoute(MainPage(), settings);

      case "/girisEkrani":
        return _generateRoute(GirisEkrani(), settings);

      case "/sifreDegistir":
        return _generateRoute(
            SifreDegistir(
              auth: settings.arguments as FirebaseAuth,
            ),
            settings);
      case "/mailDegistir":
        return _generateRoute(
            MailDegistir(
              auth: settings.arguments as FirebaseAuth,
            ),
            settings);

      case "/girisKontrol":
        return _generateRoute(GirisKontrol(), settings);

      case "/ayarlar":
        return _generateRoute(Ayarlar(), settings);

      case "/searchPage":
        return CupertinoPageRoute(
            builder: (context) => SearchPage(), settings: settings);
      case "/kullaniciGuncelle":
        return _generateRoute(
            KullaniciGuncelle(
              userId: settings.arguments as String,
            ),
            settings);
      case "/personalChat":
        return _generateRoute(
            PersonalChat(
              senderId: (settings.arguments as List<String>)[0],
              reciverId: (settings.arguments as List<String>)[1],
            ),
            settings);

      case "/telNoGiris":
        return _generateRoute(TelefonNumarasiGiris(), settings);

      case "/chatRoom":
        return _generateRoute(ChatRoom(), settings);

      case "/telNoDogrulama":
        return _generateRoute(TelNoDogrulama(), settings);

      case "/anaSayfa":
        return _generateRoute(
            AnaSayfa(
                // user: settings.arguments as User,
                // bunun bir mantıgı yok, auth.currentuser ile giris yapan kullaniciya
                // ersisebiliriz
                ),
            settings);

      // unknown page
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text("Unknown Route"),
            ),
            body: const Center(
              child: Text("404"),
            ),
          ),
        );
    }
  }
}
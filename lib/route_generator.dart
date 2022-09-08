import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/chat/%C4%B1mg_page.dart';
import 'package:flutter_firebase_auth/chat/group_add_friend.dart';
import 'package:flutter_firebase_auth/chat/group_chat.dart';
import 'package:flutter_firebase_auth/chat/group_create_page.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/ayarlar.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/kullanici_guncelle.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/mail_degistir.dart';
import 'package:flutter_firebase_auth/widgets/ayarlar/sifre_degistir.dart';
import 'package:flutter_firebase_auth/chat/groups.dart';
import 'package:flutter_firebase_auth/widgets/giris/giris_ekrani.dart';
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
        return _generateRoute(GirisKontrol(), settings);

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

      case "/imgPage":
        return _generateRoute(
            ImgPage(
              imgUrl: settings.arguments as String,
            ),
            settings);

      case "/girisKontrol":
        return _generateRoute(GirisKontrol(), settings);

      case "/groupCreatePage":
        return _generateRoute(GroupCreatePage(), settings);

      case "/ayarlar":
        return _generateRoute(Ayarlar(), settings);

      case "/searchPage":
        return CupertinoPageRoute(
          builder: (context) => SearchPage(
            friends: settings.arguments as List<dynamic>,
          ),
          settings: settings,
        );
      case "/kullaniciGuncelle":
        return _generateRoute(
            KullaniciGuncelle(
              userId: settings.arguments as String,
            ),
            settings);
      case "/personalChat":
        return CupertinoPageRoute(
          builder: (context) => PersonalChat(
            senderId: (settings.arguments as List<String>)[0],
            reciverId: (settings.arguments as List<String>)[1],
          ),
          settings: settings,
        );

      case "/telNoGiris":
        return _generateRoute(TelefonNumarasiGiris(), settings);

      case "/groups":
        return _generateRoute(Groups(), settings);

      case "/groupAddFriend":
        return _generateRoute(
            GroupAddFriend(
              groupId: (settings.arguments as List<dynamic>)[0] as String,
              groupUserIdList:
                  (settings.arguments as List<dynamic>)[1] as List<dynamic>,
            ),
            settings);

      case "/groupChat":
        return CupertinoPageRoute(
          builder: (context) => GroupChat(
            groupId: (settings.arguments as List<dynamic>)[0] as String,
            groupName: (settings.arguments as List<dynamic>)[1] as String,
            groupUserIdList:
                (settings.arguments as List<dynamic>)[2] as List<dynamic>,
          ),
          settings: settings,
        );

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

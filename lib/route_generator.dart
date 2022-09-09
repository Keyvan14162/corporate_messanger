import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/widgets/%C4%B1mg_page.dart';
import 'package:flutter_firebase_auth/widgets/groups/group_add_friend.dart';
import 'package:flutter_firebase_auth/widgets/groups/group_chat.dart';
import 'package:flutter_firebase_auth/widgets/groups/group_create_page.dart';
import 'package:flutter_firebase_auth/widgets/home_page.dart';
import 'package:flutter_firebase_auth/widgets/friends/personal_chat.dart';
import 'package:flutter_firebase_auth/widgets/friends/search_page.dart';
import 'package:flutter_firebase_auth/widgets/groups/groups.dart';
import 'package:flutter_firebase_auth/widgets/login/login_control.dart';
import 'package:flutter_firebase_auth/widgets/login/login_screen.dart';
import 'package:flutter_firebase_auth/widgets/phone_no/phone_no_login.dart';
import 'package:flutter_firebase_auth/widgets/phone_no/phone_no_verification.dart';
import 'package:flutter_firebase_auth/widgets/settings/settings.dart';
import 'package:flutter_firebase_auth/widgets/settings/user_update.dart';
import 'package:flutter_firebase_auth/widgets/settings/mail_change.dart';
import 'package:flutter_firebase_auth/widgets/settings/password_change.dart';
import 'constants.dart' as Constants;

class RouteGenerator {
  static Route<dynamic>? _generateRoute(
      Widget togoPage, RouteSettings settings) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return MaterialPageRoute(
          builder: (context) => togoPage, settings: settings);
    } else {
      return CupertinoPageRoute(
          builder: (context) => togoPage, settings: settings);
    }
  }

  static Route<dynamic>? routeGenrator(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return _generateRoute(LoginControl(), settings);

      case Constants.LOGIN_SCREEN_PATH:
        return _generateRoute(LoginScreen(), settings);

      case Constants.PASSWORD_CHANGE_PATH:
        return _generateRoute(
            PasswordChange(
              auth: settings.arguments as FirebaseAuth,
            ),
            settings);
      case Constants.MAIL_CHNAGE_PATH:
        return _generateRoute(
            MailChange(
              auth: settings.arguments as FirebaseAuth,
            ),
            settings);

      case Constants.IMG_PAGE_PATH:
        return _generateRoute(
            ImgPage(
              imgUrl: settings.arguments as String,
            ),
            settings);

      case Constants.LOGIN_CONTROL_PATH:
        return _generateRoute(LoginControl(), settings);

      case Constants.GROUP_CREATE_PAGE_PATH:
        return _generateRoute(GroupCreatePage(), settings);

      case Constants.SETTINGS_PATH:
        return _generateRoute(Settings(), settings);

      case Constants.SEARCH_PAGE_PATH:
        return CupertinoPageRoute(
          builder: (context) => SearchPage(
            friends: settings.arguments as List<dynamic>,
          ),
          settings: settings,
        );
      case Constants.USER_UPDATE_PATH:
        return _generateRoute(
            UserUpdate(
              userId: settings.arguments as String,
            ),
            settings);
      case Constants.PERSONAL_CHAT_PATH:
        return CupertinoPageRoute(
          builder: (context) => PersonalChat(
            senderId: (settings.arguments as List<String>)[0],
            reciverId: (settings.arguments as List<String>)[1],
          ),
          settings: settings,
        );

      case Constants.PHONE_NO_LOGIN_PATH:
        return _generateRoute(PhoneNoLogin(), settings);

      case Constants.GROUPS_PATH:
        return _generateRoute(Groups(), settings);

      case Constants.GROUP_ADD_FRIEND_PATH:
        return _generateRoute(
            GroupAddFriend(
              groupId: (settings.arguments as List<dynamic>)[0] as String,
              groupUserIdList:
                  (settings.arguments as List<dynamic>)[1] as List<dynamic>,
            ),
            settings);

      case Constants.GROUP_CHAT_PATH:
        return CupertinoPageRoute(
          builder: (context) => GroupChat(
            groupId: (settings.arguments as List<dynamic>)[0] as String,
            groupName: (settings.arguments as List<dynamic>)[1] as String,
            groupUserIdList:
                (settings.arguments as List<dynamic>)[2] as List<dynamic>,
          ),
          settings: settings,
        );

      case Constants.PHONE_NO_VERIFICATION_PATH:
        return _generateRoute(PhoneNoVerification(), settings);

      case Constants.HOME_PAGE_PATH:
        return _generateRoute(HomePage(), settings);

      // unknown page
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text("Unknown Route"),
            ),
            body: const Center(
              child: Text("404"),
            ),
          ),
        );
    }
  }
}

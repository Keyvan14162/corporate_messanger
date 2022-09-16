import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/chat_helpers.dart';
import 'package:flutter_firebase_auth/constants.dart' as Constants;
import 'package:flutter_firebase_auth/widgets/settings/profile_img.dart';

class PersonDialogBox extends StatelessWidget {
  const PersonDialogBox(
      {required this.reciverId,
      required this.name,
      required this.profileImgUrl,
      super.key});
  final String name;
  final String reciverId;
  final String profileImgUrl;
  final double padding = 20;
  final double avatarRadius = 45;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
    ;
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: padding,
            top: avatarRadius + padding,
            right: padding,
            bottom: padding,
          ),
          margin: EdgeInsets.only(top: avatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: avatarRadius,
              ),
              Text(
                name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: padding,
              ),
              const Text(
                "remove friend",
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        removeFriend(FirebaseAuth.instance.currentUser!.uid,
                            reciverId, context, true);
                      },
                      child: const Text(
                        "Remove Friend",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ), // bottom part
        Positioned(
          left: padding,
          right: padding,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              maxRadius: 70,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Theme.of(context).primaryColor,
                child: CircleAvatar(
                  radius: 60,
                  // backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    profileImgUrl,
                  ),
                ),
              ),
            ),
          ),
        ), // top part
      ],
    );
  }
}

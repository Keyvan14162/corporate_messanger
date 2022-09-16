import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/helpers/login_helpers.dart';
import 'package:image_picker/image_picker.dart';

class MySnackbar {
  static SnackBar getSnackbar(String message) {
    return SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      action: SnackBarAction(
        label: 'Tamam',
        onPressed: () {},
      ),
    );
  }

  static SnackBar getGalleryCameraSnackbar(Color color, BuildContext context) {
    return SnackBar(
      padding: const EdgeInsets.all(0),
      duration: const Duration(seconds: 3000000),
      dismissDirection: DismissDirection.down,
      backgroundColor: color.withAlpha(100),
      elevation: 0,
      content: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Profile Image",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.blue),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            chooseProfileImg(
                              FirebaseAuth.instance.currentUser!.uid,
                              ImageSource.camera,
                            );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              getSnackbar("Image Succesfully Changed."),
                            );
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Text(
                          "Camera",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.blue,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            chooseProfileImg(
                              FirebaseAuth.instance.currentUser!.uid,
                              ImageSource.gallery,
                            );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              getSnackbar("Image Succesfully Changed."),
                            );
                          },
                          icon: const Icon(
                            Icons.browse_gallery,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Text(
                          "Gallery",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

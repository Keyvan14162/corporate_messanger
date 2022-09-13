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

  static SnackBar getGalleryCameraSnackbar(Color color) {
    return SnackBar(
      duration: const Duration(seconds: 30),
      backgroundColor: color.withAlpha(100),
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile Image",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          chooseProfileImg(
                            FirebaseAuth.instance.currentUser!.uid,
                            ImageSource.camera,
                          );
                        },
                        icon: const Icon(
                          Icons.camera_alt,
                        ),
                      ),
                    ),
                    const Text(
                      "Camera",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          chooseProfileImg(
                            FirebaseAuth.instance.currentUser!.uid,
                            ImageSource.gallery,
                          );
                        },
                        icon: const Icon(
                          Icons.browse_gallery,
                        ),
                      ),
                    ),
                    const Text(
                      "Gallery",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      action: SnackBarAction(
        textColor: color,
        label: 'Close',
        onPressed: () {},
      ),
    );
  }
}

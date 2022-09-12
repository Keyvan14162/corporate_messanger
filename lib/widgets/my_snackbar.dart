import 'package:flutter/material.dart';

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
}

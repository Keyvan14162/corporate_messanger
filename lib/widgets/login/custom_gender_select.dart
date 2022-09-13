import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/widgets/login/gender.dart';

class CustomGenderSelect extends StatelessWidget {
  const CustomGenderSelect(this._gender, {required this.cardColor, Key? key})
      : super(key: key);
  final Gender _gender;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: _gender.isSelected ? cardColor : Colors.white,
      child: Container(
        height: 90,
        width: 90,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _gender.icon,
              color: _gender.isSelected ? Colors.white : Colors.grey,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _gender.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _gender.isSelected ? Colors.white : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}

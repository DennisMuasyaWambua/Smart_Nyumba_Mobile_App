import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class FieldLabel extends StatelessWidget {
  final String labelName;
  const FieldLabel({super.key, required this.labelName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 40),
      child: Text(
        labelName,
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: lightGrey,
          fontSize: 13,
          fontFamily: 'karala',
          fontWeight: FontWeight.w300,
          letterSpacing: 1.40,
        ),
      ),
    );
  }
}

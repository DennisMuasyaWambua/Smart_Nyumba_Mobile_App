import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class RegisterInputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final String hintText;

  const RegisterInputField({
    super.key,
    required this.controller,
    required this.prefixIcon,
    required this.hintText,
    required this.keyboardType,
    required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            color: royalBlue,
          ),
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

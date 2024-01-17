import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class RegisterInputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String hintText;

  const RegisterInputField({
    super.key,
    required this.controller,
    required this.prefixIcon,
    required this.hintText,
    required this.keyboardType,
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
        style: const TextStyle(
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          constraints: BoxConstraints(minWidth: 100, maxWidth: MediaQuery.of(context).size.width),
          prefixIcon: Icon(
            prefixIcon,
            color: royalBlue,
          ),
          hintText: hintText,
          contentPadding: const EdgeInsets.only(
            left: 25,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

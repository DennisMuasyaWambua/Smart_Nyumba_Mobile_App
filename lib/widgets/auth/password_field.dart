import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final Widget? prefixIcon;
  final String? hintText;
  const PasswordField({super.key, required this.controller, this.prefixIcon, this.hintText});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _passwordVisible = true;

  void _tooglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        obscureText: _passwordVisible,
        controller: widget.controller,
        keyboardType: TextInputType.visiblePassword,
        style: const TextStyle(
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.only(left: 25),
          prefixIcon: widget.prefixIcon,
          suffixIcon: InkWell(
            onTap: _tooglePasswordVisibility,
            child: _passwordVisible
                ? const Icon(
                    Icons.visibility,
                    color: royalBlue,
                  )
                : const Icon(
                    Icons.visibility_off,
                    color: royalBlue,
                  ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

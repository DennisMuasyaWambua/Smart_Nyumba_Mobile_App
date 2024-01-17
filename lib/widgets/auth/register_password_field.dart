import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class RegisterPasswordField extends StatefulWidget {
  final TextEditingController controller;

  const RegisterPasswordField({super.key, required this.controller});

  @override
  State<RegisterPasswordField> createState() => _RegisterPasswordFieldState();
}

class _RegisterPasswordFieldState extends State<RegisterPasswordField> {
  bool _isVisible = true;

  void _tooglePasswordView() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
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
          obscureText: _isVisible,
          controller: widget.controller,
          keyboardType: TextInputType.visiblePassword,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "Password",
            alignLabelWithHint: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
            prefixIcon: const Icon(
              Icons.security,
              color: royalBlue,
            ),
            suffixIcon: InkWell(
              onTap: _tooglePasswordView,
              child: _isVisible
                  ? const Icon(
                      Icons.visibility,
                      color: royalBlue,
                    )
                  : const Icon(
                      Icons.visibility_off,
                      color: royalBlue,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

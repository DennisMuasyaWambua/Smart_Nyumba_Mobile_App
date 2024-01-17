import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const PasswordField({
    super.key,
    required this.controller,
  });

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
      height: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
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
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
          suffixIcon: InkWell(
            onTap: _tooglePasswordVisibility,
            child:
                _passwordVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
          ),
        ),
      ),
    );
  }
}

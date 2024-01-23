import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final Widget text;
  final Function()? onClick;
  final List<Color> buttonBgColor;

  const AuthButton(
      {super.key, required this.text, required this.onClick, required this.buttonBgColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.only(top: 2, bottom: 2.98),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.97, 0.24),
            end: const Alignment(0.97, -0.24),
            colors: buttonBgColor,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: text,
      ),
    );
  }
}

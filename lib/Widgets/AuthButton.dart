import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton(
      {Key? key,
      required this.text,
      required this.onClick,
      required this.textColor})
      : super(key: key);
  final text, onClick;
  final List<Color> textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 301.40,
        height: 49.98,
        padding: const EdgeInsets.only(top: 2, bottom: 2.98),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.97, 0.24),
            end: const Alignment(0.97, -0.24),
            colors: textColor,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$text',
              textAlign: TextAlign.center,
              style: const TextStyle(
                decoration: TextDecoration.none,
                color: Colors.white,
                fontSize: 27,
                fontFamily: 'Hind',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

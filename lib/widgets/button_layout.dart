import 'package:flutter/material.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';

class ButtonLayout extends StatelessWidget {
  final double width;
  final double? height;
  final Widget text;
  final Function()? onClick;

  const ButtonLayout({
    super.key,
    required this.width,
    this.height,
    required this.text,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: width,
        height: height ?? 40,
        padding: const EdgeInsets.only(top: 2, bottom: 2.98, left: 20, right:20,),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.97, 0.24),
            end: Alignment(0.97, -0.24),
            colors: gradYellowGold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(child: text),
      ),
    );
  }
}

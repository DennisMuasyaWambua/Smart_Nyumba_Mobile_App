import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';


class Logo extends StatelessWidget {
  const Logo({Key? key, required this.height, required this.width}) : super(key: key);
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return  Neumorphic(
      style: const NeumorphicStyle(
          shape: NeumorphicShape.concave,
          depth: 100,
          boxShape: NeumorphicBoxShape.circle(),
          lightSource: LightSource.topLeft,
          intensity: 30
      ),
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage("assets/images/smartnyumba.png"),

            )

        ),
      ),
    );
  }
}

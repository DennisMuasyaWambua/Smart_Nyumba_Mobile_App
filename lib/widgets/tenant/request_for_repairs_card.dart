import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/constants.dart';

class RequestForRepairsCard extends StatelessWidget {
  const RequestForRepairsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.5,right: 5.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height*0.22,
          width: MediaQuery.of(context).size.width*0.40,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              shadows: const [
                BoxShadow(
                  color: Color(0x19A3A3A3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.plumbing_rounded,
                color: Colors.black,
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 5.0,right: 5.0),
                child: Text(
                  Constants.service,
                  style: GoogleFonts.hind(
                      height: 1.33,
                      letterSpacing: -0.24,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
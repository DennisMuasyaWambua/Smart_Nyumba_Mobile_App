
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';

import '../../utils/constants/constants.dart';
import 'pay_service_charge_alert_dialog.dart';

// ignore: must_be_immutable
class PayServiceChargeCard extends StatelessWidget {
  int hasUserPaid;
  PayServiceChargeCard({super.key, required this.hasUserPaid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const PayServiceChargeAlertDialog(),
        );
        
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 0.5, right: 5.0),
        child: Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.concave,
              depth: 100,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(25.0),
              ),
              lightSource: LightSource.topLeft,
              intensity: 30),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.22,
            width: MediaQuery.of(context).size.width * 0.40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.97, 0.24),
                end: Alignment(0.97, -0.24),
                colors: gradYellowGold,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        Constants.payServiceCharge,
                        style: GoogleFonts.hind(
                            letterSpacing: -0.24,
                            height: 1.33,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

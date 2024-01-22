import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/constants.dart';

class PaymentStatementCard extends StatelessWidget {
  const PaymentStatementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // payment status
        // var history = Provider.of<Payments>(context, listen: false)
        //     .getAllTransactions();
        //
        // history.then((value) {
        //
        //   for (int i = 0; i < value!.length; i++) {
        //        log(value[i].toJson().toString(),
        //       name: "HISTORIC TRANSACTIONS");
        //       // get information from here on all transactions and form the system
        //   }
        // });
        Navigator.pushNamed(context, '/allServiceChargeTransactions');
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(children: [
                const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
                  child: Text(
                    Constants.paymentHistory,
                    style: GoogleFonts.hind(
                      height: 1.33,
                      fontSize: 15,
                      letterSpacing: -0.24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

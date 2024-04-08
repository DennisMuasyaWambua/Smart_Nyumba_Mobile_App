import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/models/all_transactions.dart';
import 'package:smart_nyumba/utils/providers/admin_provider.dart';
import '../../widgets/admin/_summary_cards.dart';

class AdminHome extends StatefulWidget {
  static const routeName = "/admin-home";

  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late AdminController tenantProvider;
  late AllTransactions adminProvider;
  @override
  void didChangeDependencies() {
    Provider.of<AdminController>(context, listen: false);
    tenantProvider = Provider.of<AdminController>(context, listen: false);
    tenantProvider.fetchTenants();
    

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 20.0),
          child: Column(
            children: [
              TenantSummaryCard(),
              SizedBox(height: 16),
              CompaniesSummaryCard(),
              SizedBox(height: 16),
              PaymentSummaryCard(),
            ],
          ),
        ),
      ),
    );
  }
}


  // Widget _addPerson() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Neumorphic(
  //       style: NeumorphicStyle(
  //           shape: NeumorphicShape.concave,
  //           depth: 100,
  //           boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
  //           lightSource: LightSource.topLeft,
  //           intensity: 30),
  //       child: GestureDetector(
  //         onTap: () {
  //           Navigator.pushNamed(context, '/createNewRole');
  //         },
  //         child: Container(
  //           height: 160,
  //           width: 135,
  //           decoration: const BoxDecoration(
  //               gradient: LinearGradient(
  //                   begin: Alignment(-0.97, 0.24),
  //                   end: Alignment(0.97, -0.24),
  //                   colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 50),
  //             child: Column(children: [
  //               const Icon(
  //                 Icons.person_add,
  //                 color: Colors.white,
  //                 size: 30,
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 8.0),
  //                 child: Text(
  //                   Constants.createRole,
  //                   style: GoogleFonts.hind(
  //                       letterSpacing: -0.24,
  //                       height: 1.33,
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.w700,
  //                       color: Colors.white),
  //                 ),
  //               )
  //             ]),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _checkCumulativeServiceChargeBalance() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Neumorphic(
  //       style: NeumorphicStyle(
  //           shape: NeumorphicShape.concave,
  //           depth: 100,
  //           boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
  //           lightSource: LightSource.topLeft,
  //           intensity: 30),
  //       child: Container(
  //         height: 160,
  //         width: 135,
  //         decoration: const BoxDecoration(
  //             gradient: LinearGradient(
  //                 begin: Alignment(-0.97, 0.24),
  //                 end: Alignment(0.97, -0.24),
  //                 colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 50),
  //           child: Column(children: [
  //             const Icon(
  //               Icons.account_balance,
  //               color: Colors.white,
  //               size: 30,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 8.0),
  //               child: Text(
  //                 Constants.serviceChargeBalance,
  //                 style: GoogleFonts.hind(
  //                     letterSpacing: -0.24,
  //                     height: 1.33,
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.white),
  //               ),
  //             )
  //           ]),
  //         ),
  //       ),
  //     ),
  //   );
  // }

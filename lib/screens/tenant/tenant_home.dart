import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/constants.dart';
import '../../utils/models/user_profile.dart';
import '../../utils/providers/auth_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/tenant/tenant_dashboard_grid.dart';

class TenantHome extends StatefulWidget {
  static const routeName = "/tenant-home";
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome> {
  int hasUserPaid = 0;
  int myIndex = 0;
  var lastName = ' ';
  var token = SharedPrefrenceBuilder.getUserToken;
  @override
  void initState() {
    super.initState();
    log(token.toString(), name: "THIS IS THE USERS TOKEN");
    final profile = Auth().getProfile(token!, context);
    profile.then((value) async {
      setState(() {
        log(value.profile!.user!.toJson().toString(), name: "FETCHING PROFILE");
        lastName = value.profile!.user!.firstName.toString();
        Provider.of<Auth>(context, listen: false)
            .setLastName(value.profile!.user!.lastName.toString());
        log(lastName.toString(), name: "USERS LAST NAME");
      });

      User? user = value.profile!.user;
      Provider.of<Auth>(context, listen: false).setUsersData(user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                Constants.dashboard,
                style: GoogleFonts.hind(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Welcome $lastName',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 30),
              child: TenantDashboardGrid(hasUserPaid: hasUserPaid),
            ),
          ],
        ),
      ),
    );
  }
}

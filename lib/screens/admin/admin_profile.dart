import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/utils/models/admin_profile.dart';
import 'package:smart_nyumba/utils/providers/auth_provider.dart';
import 'package:smart_nyumba/utils/providers/shared_preference_builder.dart';
import 'package:smart_nyumba/widgets/auth/logout_button.dart';

class AdminProfile extends StatefulWidget {
  static const routeName = "/admin-profile";

  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String? email;
  var token = SharedPrefrenceBuilder.getUserToken;
  var name, phoneNumber;
  AdProfile? profile;

  @override
  void initState() {
    super.initState();
    email = SharedPrefrenceBuilder.getUserEmail;
    final account = Auth().getAdminProfile(token!);
    account.then((value) {
      log(value.toString(), name: "ADMIN ACCOUNT");
      setState(() {
        profile = value;
        name = profile!.name;
        phoneNumber = profile!.phoneNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/account_icon.png"),
                            radius: 34,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name.toString(),
                            style: GoogleFonts.hind(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: const Color(0xFF1A1E25),
                            ),
                          ),
                          Text(
                            email.toString(),
                            style: GoogleFonts.hind(
                              color: const Color(0xFF7D7F88),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Phone Number",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                                Text(phoneNumber.toString()),
                          const SizedBox(height: 12),
                          // const Text(
                          //   "House Number",
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          // const Text("4"),
                          // const SizedBox(height: 4),
                          LogoutButton(email: email)
                        ],
                      ),
                    ),
                  ),
                  // const LogoutButton(email: ,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/auth/logout_button.dart';

class AdminProfile extends StatelessWidget {
  static const routeName = "/admin-profile";

  const AdminProfile({super.key});

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
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/account_icon.png"),
                      radius: 30,
                    ),
                    title: Text(
                      'Chairman',
                      style: GoogleFonts.hind(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1E25),
                      ),
                    ),
                    subtitle: Text(
                      'smartnyumba@gmail.com',
                      style: GoogleFonts.hind(
                        color: const Color(0xFF7D7F88),
                      ),
                    ),
                  ),
                  const LogoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

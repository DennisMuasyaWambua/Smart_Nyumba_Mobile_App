import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


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
                  Card(
                    elevation: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage("assets/images/account_icon.png"),
                            radius: 34,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Chairman",
                            style: GoogleFonts.hind(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: const Color(0xFF1A1E25),
                            ),
                          ),
                          Text(
                            "smartnyumba@gmail.com",
                            style: GoogleFonts.hind(
                              color: const Color(0xFF7D7F88),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Block Number",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text("12"),
                          const SizedBox(height: 12),
                          const Text(
                            "House Number",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text("4"),
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

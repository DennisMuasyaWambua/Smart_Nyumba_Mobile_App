import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/screens/admin/_admin.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: ListView(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Companies(),
                        ),
                      );
                    },
                    title: Text(
                      'Companies',
                      style: GoogleFonts.hind(),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  ListTile(
                    onTap: () {},
                    title: Text(
                      'Payments',
                      style: GoogleFonts.hind(),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EstateTenants(),
                        ),
                      );
                    },
                    title:Text(
                      'Tenants',
                      style: GoogleFonts.hind(),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

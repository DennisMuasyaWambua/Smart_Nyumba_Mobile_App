import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../screens/admin/companies.dart';

class CompaniesSummaryCard extends StatelessWidget {
  const CompaniesSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(Companies.routeName),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Companies",
                style: GoogleFonts.hind(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
             const SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "2",
                            style:  TextStyle(fontSize: 32),
                          ),
                           SizedBox(height: 10),
                          Text("Active"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "2",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.grey, // Assuming lightGrey is a Color variable
                            ),
                          ),
                           SizedBox(height: 10),
                          Text("Past"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

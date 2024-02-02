import 'package:flutter/material.dart';

import '../../screens/admin/_admin.dart';
import '../../utils/constants/colors.dart';

class CompaniesSummaryCard extends StatelessWidget {
    CompaniesSummaryCard({super.key});

    @override
    return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(Companies.routeName);
        child: Card(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, 
                    vertical: 20,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                        Text(
                            "Companies",
                            style: GoogleFonts.hind(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        SizedBox(
                            height: 150, 
                            child: Row(
                                children: [
                                    Expanded(
                                        child: Column(
                                            children: [
                                                Text(
                                                    "2",
                                                    style: const TextStyle(fontSize: 32),
                                                ),
                                                const SizedBox(height: 10),
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
                                                        color: lightGrey,
                                                    ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text("Past")
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
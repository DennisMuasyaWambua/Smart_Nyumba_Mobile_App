import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/colors.dart';

class DashboardActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;

  const DashboardActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: locked
              ? LinearGradient(
                  colors: [
                    Colors.grey.shade500,
                    Colors.grey.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFF4A90E2),
                    Color(0xFF357ABD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (locked ? Colors.grey : Colors.blue).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: locked ? Colors.white70 : Colors.white,
                ),
                if (locked)
                  const Positioned(
                    right: -8,
                    bottom: -4,
                    child: Icon(
                      Icons.lock,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: locked ? Colors.white70 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

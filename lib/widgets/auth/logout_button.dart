import 'package:flutter/material.dart';

import '../button_layout.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 20,
        ),
        ButtonLayout(
          width: 120,
          borderRadius: 4,
          padding: const EdgeInsets.symmetric(vertical: 2),
          text: const Text(
            "Logout",
            style: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: 'Hind',
              fontWeight: FontWeight.w500,
            ),
          ),
          onClick: () {},
        ),
      ],
    );
  }
}

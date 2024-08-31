import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_nyumba/screens/authentication/_auth.dart';
import 'package:smart_nyumba/utils/providers/_providers.dart';
import 'package:smart_nyumba/utils/providers/auth_provider.dart';

import '../button_layout.dart';

class LogoutButton extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final email;
  const LogoutButton({super.key, required this.email});

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
          onClick: () {
            // send a request to logout
            log(
              email.toString(),
              name: "LOGOUT EMAIL",
            );

            var out = Auth().logout(email);
            out.then((value) {
              if (value.toString() == 'true') {
                Navigator.of(context).pushReplacementNamed(Login.routeName);
              }
            });
          },
        ),
      ],
    );
  }
}

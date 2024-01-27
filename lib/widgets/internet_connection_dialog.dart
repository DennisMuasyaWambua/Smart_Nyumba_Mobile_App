import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

class InternetConnectionDialog extends StatelessWidget {
  const InternetConnectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("Connection Alert"),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: lightGrey,
            size: 48,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Check your internet connection and try again",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              minimumSize: const MaterialStatePropertyAll(
                Size.fromHeight(40),
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return lightGold.withOpacity(0.18);
                  }
                  return null;
                },
              ),
              shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            child: const Text(
              "Close",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

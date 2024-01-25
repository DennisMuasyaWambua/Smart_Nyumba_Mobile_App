import 'package:flutter/material.dart';
import 'package:smart_nyumba/widgets/button_layout.dart';

class PayServiceChargeAlertDialog extends StatefulWidget {
  const PayServiceChargeAlertDialog({super.key});

  @override
  State<PayServiceChargeAlertDialog> createState() => _PayServiceChargeAlertDialogState();
}

class _PayServiceChargeAlertDialogState extends State<PayServiceChargeAlertDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pay Service Charge"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter your phone number:"),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: controller,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 6,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            ButtonLayout(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 0,
              ),
              borderRadius: 4,
              text: const Text(
                'Pay',
                style: TextStyle(color: Colors.white),
              ),
              onClick: () {},
            ),
          ],
        ),
      ],
    );
  }
}

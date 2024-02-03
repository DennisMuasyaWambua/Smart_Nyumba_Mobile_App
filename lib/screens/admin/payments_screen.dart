import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  static const routeName = "/payments";
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
      ),
      body: const SingleChildScrollView(
        child: Column(),
      ),
    );
  }
}

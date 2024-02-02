import 'package:flutter/material.dart';

class MarketPlace extends StatelessWidget {
  static const routeName = "/marketplace";

  const MarketPlace({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Text("Welcome to Akilla 2 Marketplace"),
            ],
          ),
        ),
      ),
    );
  }
}

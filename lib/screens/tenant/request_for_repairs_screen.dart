import 'package:flutter/material.dart';
import 'package:smart_nyumba/utils/models/user_profile.dart';

import '../../utils/providers/_providers.dart';

class RequestForRepairsScreen extends StatefulWidget {
  static const routeName = "/request-for-repairs";
  const RequestForRepairsScreen({super.key});

  @override
  State<RequestForRepairsScreen> createState() => _RequestForRepairsScreenState();
}

class _RequestForRepairsScreenState extends State<RequestForRepairsScreen> {
  bool tokenPresent = false;
  late TextEditingController blockNumberController;
  late TextEditingController houseNumberController;
  late Future<UserProfile> account;

  @override
  void initState() {
    blockNumberController = TextEditingController();
    houseNumberController = TextEditingController();

    String? token = SharedPrefrenceBuilder.getUserToken;

    if (token == null) {
      setState(() {
        tokenPresent = false;
      });
    } else {
      setState(() {
        tokenPresent = true;
      });
    }

    account = Auth().getProfile(token!, context);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    account.then((value) async {
      blockNumberController.text = value.profile!.propertyBlock!.block!.toString();
      houseNumberController.text = value.profile!.propertyBlock!.houseNumber!;
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    blockNumberController.dispose();
    houseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request for Repair"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Block No."),
              ),
              TextFormField(
                controller: blockNumberController,
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
              const Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  bottom: 8.0,
                ),
                child: Text("House No."),
              ),
              TextFormField(
                controller: houseNumberController,
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
        ),
      ),
    );
  }
}

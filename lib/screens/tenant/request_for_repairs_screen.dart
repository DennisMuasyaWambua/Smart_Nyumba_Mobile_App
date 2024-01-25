import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../utils/models/user_profile.dart';
import '../../utils/providers/_providers.dart';
import '../../widgets/button_layout.dart';

enum RepairType { plumbing, electrical, flooring, woodwork, glasswork, other }

class RequestForRepairsScreen extends StatefulWidget {
  static const routeName = "/request-for-repairs";
  const RequestForRepairsScreen({super.key});

  @override
  State<RequestForRepairsScreen> createState() => _RequestForRepairsScreenState();
}

class _RequestForRepairsScreenState extends State<RequestForRepairsScreen> {
  bool tokenPresent = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController blockNumberController;
  late TextEditingController houseNumberController;
  late TextEditingController descriptionController;
  late Future<UserProfile> account;

  RepairType repairType = RepairType.plumbing;
  bool requestRepairForMe = false;
  bool requestRepairForNeighbour = false;
  bool requestRepairForBoth = false;

  String defaultBlockNumber = "";
  String defaultHouseNumber = "";

  @override
  void initState() {
    blockNumberController = TextEditingController();
    houseNumberController = TextEditingController();
    descriptionController = TextEditingController();

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

    account.then((value) async {
      defaultBlockNumber = value.profile!.propertyBlock!.block!.toString();
      defaultHouseNumber = value.profile!.propertyBlock!.houseNumber!;
      blockNumberController.text = value.profile!.propertyBlock!.block!.toString();
      houseNumberController.text = value.profile!.propertyBlock!.houseNumber!;
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (defaultBlockNumber == blockNumberController.text &&
        defaultHouseNumber == houseNumberController.text) {
      setState(() {
        requestRepairForMe = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    blockNumberController.dispose();
    houseNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request for Repair"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                  onChanged: (value) {
                    if (value.isNotEmpty && value != defaultBlockNumber) {
                      setState(() {
                        requestRepairForMe = false;
                      });
                    } else if (value.isNotEmpty && value == defaultBlockNumber) {
                      setState(() {
                        requestRepairForMe = true;
                      });
                    }
                  },
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
                  onChanged: (value) {
                    if (value.isNotEmpty && value != defaultHouseNumber) {
                      setState(() {
                        requestRepairForMe = false;
                      });
                    } else if (value.isNotEmpty && value == defaultHouseNumber) {
                      setState(() {
                        requestRepairForMe = true;
                      });
                    }
                  },
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
                  child: Text("Repair Type"),
                ),
                DropdownButton2(
                  value: repairType,
                  items: const [
                    DropdownMenuItem(
                      value: RepairType.plumbing,
                      child: Text("Plumbing"),
                    ),
                    DropdownMenuItem(
                      value: RepairType.electrical,
                      child: Text("Electrical"),
                    ),
                    DropdownMenuItem(
                      value: RepairType.flooring,
                      child: Text("Flooring"),
                    ),
                    DropdownMenuItem(
                      value: RepairType.woodwork,
                      child: Text("Furniture/Wood work"),
                    ),
                    DropdownMenuItem(
                      value: RepairType.glasswork,
                      child: Text("Glasswork"),
                    ),
                    DropdownMenuItem(
                      value: RepairType.other,
                      child: Text("Other"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      repairType = value!;
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 24,
                    bottom: 8.0,
                  ),
                  child: Text("Description"),
                ),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
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
                  child: Text("Media"),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  child: const Text(
                    "Insert Media",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 24,
                    bottom: 8.0,
                  ),
                  child: Text("Requesting for"),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: requestRepairForMe,
                      activeColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          requestRepairForMe = value!;
                          requestRepairForNeighbour = false;
                          requestRepairForBoth = false;
                        });
                      },
                    ),
                    const Text("Me"),
                    Checkbox(
                      value: requestRepairForNeighbour,
                      activeColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          requestRepairForNeighbour = value!;
                          requestRepairForMe = false;
                          requestRepairForBoth = false;
                        });
                      },
                    ),
                    const Text("Neighbour"),
                    Checkbox(
                      value: requestRepairForBoth,
                      activeColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          requestRepairForBoth = value!;
                          requestRepairForMe = false;
                          requestRepairForNeighbour = false;
                        });
                      },
                    ),
                    const Text("Both"),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ButtonLayout(
                    borderRadius: 4,
                    text: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onClick: () {},
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

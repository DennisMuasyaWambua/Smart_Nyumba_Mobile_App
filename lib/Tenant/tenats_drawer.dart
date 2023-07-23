import 'package:flutter/material.dart';

class TenantsDrawer extends StatefulWidget {
  const TenantsDrawer({super.key});

  @override
  State<TenantsDrawer> createState() => _TenantsDrawerState();
}

class _TenantsDrawerState extends State<TenantsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: const Text("accountName"),
             accountEmail: const Text("accountEmail"))
        ],
      ),
    );
  }
}
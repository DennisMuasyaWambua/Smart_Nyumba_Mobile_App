import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class RegisterRoleDropdown extends StatelessWidget {
  final String? selectedRole;
  final Function(String?) onChanged;

  const RegisterRoleDropdown({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.work_outline,
            color: royalBlue,
          ),
          hintText: "Select Role",
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(
            value: 'tenant',
            child: Text('Tenant'),
          ),
          DropdownMenuItem(
            value: 'landlord',
            child: Text('Landlord'),
          ),
          DropdownMenuItem(
            value: 'accounts',
            child: Text('Accounts'),
          ),
          DropdownMenuItem(
            value: 'caretaker',
            child: Text('Caretaker'),
          ),
        ],
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.black87,
        ),
      ),
    );
  }
}

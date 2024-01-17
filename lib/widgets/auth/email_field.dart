import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  const EmailField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(left: 25),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

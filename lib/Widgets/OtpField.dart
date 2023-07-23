import 'package:flutter/material.dart';

class OtpField extends StatefulWidget {
  const OtpField({Key? key, required this.numberInput}) : super(key: key);
  final numberInput;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  var numberInput = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextFormField(
        controller: numberInput,
        onChanged: (value) {
          value = numberInput.text;
        },
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0)),
            hintText: '*',
            filled: true,
            fillColor: Colors.grey.shade200),
      ),
    );
  }
}

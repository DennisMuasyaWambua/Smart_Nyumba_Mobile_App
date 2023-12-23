import 'package:flutter/material.dart';

class Alert{
  Widget alert(String message){
    return AlertDialog(
        content: Text(message),
    );
  }
}
import 'package:flutter/material.dart';


InputDecoration textBoxStyle(
    String hintText, String label, IconData iconData) {
  return InputDecoration(
    hintText: hintText,
    labelText: label,
    prefixIcon: Icon(iconData, color: Colors.cyan.shade700),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.cyan.shade700, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.cyan.shade700, width: 2.0),
    ),
  );
}

InputDecoration textBoxStyle1(String hintText, String label) {
  return InputDecoration(
    hintText: hintText,
    label: Text(label),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
    )
  );
}

TextStyle myTextStyle(){
  return TextStyle(
    fontSize: 20.0,
    color: Colors.red,
    fontWeight: FontWeight.bold
  );
}
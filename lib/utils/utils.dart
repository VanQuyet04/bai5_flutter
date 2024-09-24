import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String title, Color color) {
  final snackBar = SnackBar(content: Text(title), backgroundColor: color);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

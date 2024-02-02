
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'localizations.dart';

showSnackBar(BuildContext context, String message) async {
  final snackBar = SnackBar(
    content: Text(message),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}

Future<bool> showConfirmDialog(BuildContext context, String message) async {

}
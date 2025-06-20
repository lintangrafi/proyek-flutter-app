// lib/utils/error_dialog.dart
import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
  );
}

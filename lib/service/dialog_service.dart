import 'package:flutter/material.dart';

class DialogService {
  void appVersionDialog(
    BuildContext context, {
    required String title,
    required String event,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            event,
            style: const TextStyle(fontSize: 18.0),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

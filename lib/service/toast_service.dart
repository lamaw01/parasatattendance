import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ToastService {
  Future<void> showToast(
    BuildContext context, {
    required String? name,
    required String message,
  }) async {
    showToastWidget(
      Container(
        height: 150.0,
        width: 300.0,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            if (name != null) ...[
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontSize: 20.0),
              ),
            ],
          ],
        ),
      ),
      context: context,
      animation: StyledToastAnimation.none,
      reverseAnimation: StyledToastAnimation.slideToBottomFade,
      position: StyledToastPosition.center,
      animDuration: const Duration(seconds: 1),
      duration: const Duration(seconds: 4),
    );
  }
}

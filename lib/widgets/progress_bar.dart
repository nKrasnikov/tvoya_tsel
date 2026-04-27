import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int progress; // 0–100
  final double height;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            widthFactor: (progress / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
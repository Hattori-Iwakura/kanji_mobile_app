import 'package:flutter/material.dart';

/// Custom back button widget that can be used consistently across all pages
///
/// Usage:
/// ```dart
/// AppBar(
///   leading: CustomBackButton(),
///   title: Text('Page Title'),
/// )
/// ```
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const CustomBackButton({super.key, this.onPressed, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: size ?? 20),
      color: color ?? Theme.of(context).iconTheme.color,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
    );
  }
}

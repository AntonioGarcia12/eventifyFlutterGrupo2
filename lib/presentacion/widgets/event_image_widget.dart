import 'dart:io';
import 'package:flutter/material.dart';

class EventImageWidget extends StatelessWidget {
  final String imagePath;
  final bool imageNetwork;
  final double? width;
  final double? height;
  final BoxFit fit;

  const EventImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.imageNetwork,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: FileImage(File(imagePath)),
      width: width,
      height: height,
      fit: fit,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Image.asset(
          'assets/images/logo.png',
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Pick Pack';
  
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 16.0;
  
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(8));
  
  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}

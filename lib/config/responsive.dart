import 'package:flutter/material.dart';
import 'dart:math' as math;

class Responsive {
  static late double _width;
  static late double _height;
  static late double _diagonal;
  static late bool _isTablet;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    _diagonal = math.sqrt((_width * _width) + (_height * _height));
    _isTablet = _diagonal > 1100.0;
  }

  static double w(double size) => size * _width / 375;
  static double h(double size) => size * _height / 812;
  static double sp(double size) => size * _diagonal / 1000;
  static double r(double size) => size * _width / 375;
  static bool get isTablet => _isTablet;
}
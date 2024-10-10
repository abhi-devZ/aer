import 'dart:math';

import 'package:flutter/material.dart';

class RandomColorGenerator {
  // Function to generate a random color
  static Color get randomColor => getRandomColor();
  static Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255, // Alpha (fully opaque)
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }
}
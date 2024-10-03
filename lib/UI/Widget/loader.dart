import 'package:flutter/material.dart';

class LoaderWidget {
  // Linear Progress Indicator Loader
  Widget linearLoader({double? value}) => LinearProgressIndicator(
        minHeight: 2.0,
        backgroundColor: Colors.grey[200], // Optional: background color
        value: value,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Loader color
      );

  // Circular Progress Indicator Loader
  Widget get circularLoader => const CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Loader color
      );

  // Gradient Circular Loader
  Widget gradientLoader({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 3.0,
        backgroundColor: Colors.transparent, // To show only the gradient
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  // Method to return the requested loader type
  Widget getLoader({required String type, double size = 40.0}) {
    switch (type) {
      case 'linear':
        return linearLoader();
      case 'circular':
        return circularLoader;
      case 'gradient':
        return gradientLoader(size: size);
      default:
        return circularLoader; // Default loader if type is unknown
    }
  }
}

LoaderWidget loader = LoaderWidget();

import 'package:aer/UI/Widget/search_box.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WidgetTestPage extends StatelessWidget {
  const WidgetTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFFAFAFA),
      body: Center(
        child: SearchBox(
          searchTerm: "Term",
          isLoading: true,
          onSubmitTextField: (value) {

          },
        ),
      ),
    );
  }
}

// Usage Example with all styles

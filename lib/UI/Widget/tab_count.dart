import 'package:flutter/material.dart';

class TabCount extends StatelessWidget {
  final int count = 10;

  const TabCount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.blueGrey, width: 1.5),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.blueGrey, fontSize: 14.0, fontWeight: FontWeight.w400),
      ),
    );
  }
}

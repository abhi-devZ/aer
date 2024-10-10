import 'package:flutter/material.dart';

class AI extends StatelessWidget {
  const AI({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ClipPath(
        clipper: ShapePainter(),
        child: Container(),
      ),
    );
  }
}

class ShapePainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {

    var path = Path();
    path.lineTo(0.0, 20.0);
    path.quadraticBezierTo(0.0, 0.0, 20.0, 0.0);

    path.lineTo(size.width - 20.0, 0.0);
    path.quadraticBezierTo(size.width, 0.0, size.width, 20.0);

    path.lineTo(size.width, size.height - 30.0);
    path.quadraticBezierTo(size.width, size.height, size.width - 30, size.height - 10);

    path.lineTo(20, size.height * 0.85);
    path.quadraticBezierTo(0.0, size.height * 0.85 - 10, 0.0, size.height * 0.85 - 20);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class CustomSnapshotController {
  final GlobalKey webViewKey = GlobalKey();
  String? snapshotPath;
  bool showSnapshot = false;
  final Offset snapshotPosition = const Offset(20, 100);

  Future<void> captureSnapshot(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary =
      webViewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${directory.path}/snapshot_$timestamp.png';

        final file = File(path);
        await file.writeAsBytes(pngBytes);
        snapshotPath = path;
        showSnapshot = true;
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  Widget buildSnapshotWindow(BuildContext context) {
    if (!showSnapshot || snapshotPath == null) return const SizedBox();

    return Positioned(
      left: snapshotPosition.dx,
      top: snapshotPosition.dy,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.44,
        height: MediaQuery.sizeOf(context).height * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Image.file(
          File(snapshotPath!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Error'),
        content: Text('Failed to capture screenshot: $error'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void dispose() {
    if (snapshotPath != null) {
      File(snapshotPath!).delete().ignore();
    }
  }
}
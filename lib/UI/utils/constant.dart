import 'dart:ui';
import 'package:logger/logger.dart';

late Size screenSize;

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);

String searchEngineUrl = "https://www.google.com/search";
String? query;
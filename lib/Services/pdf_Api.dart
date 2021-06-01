import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PDFApi {
  static Future<File> loadAssetPDF(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asInt8List();
    return await _storeFile(path, bytes);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

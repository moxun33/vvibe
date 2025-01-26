import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:vvibe/utils/logger.dart';

// 解压gzip
Future<bool> unzipGzip(String gzPath, String extractPath) async {
  try {
    File compressedFile = File(gzPath);

    List<int> compressedBytes = await compressedFile.readAsBytes();

    GZipDecoder decoder = GZipDecoder();
    List<int> decompressedBytes = decoder.decodeBytes(compressedBytes);

    File decompressedFile = File(extractPath);
    await decompressedFile.writeAsBytes(decompressedBytes);

    MyLogger.info(gzPath + '解压完成！' + extractPath);
    return true;
  } catch (e) {
    MyLogger.error('解压 $gzPath 出错' + e.toString());
    return false;
  }
}

// 解压zip
Future<bool> unzipZip(String gzPath, String extractPath) async {
  try {
    final inputStream = InputFileStream(gzPath);

    final archive = ZipDecoder().decodeBuffer(inputStream);
    extractArchiveToDisk(archive, extractPath);

    MyLogger.info(gzPath + '解压完成！' + extractPath);
    return true;
  } catch (e) {
    MyLogger.error('解压 $gzPath 出错' + e.toString());
    return false;
  }
}

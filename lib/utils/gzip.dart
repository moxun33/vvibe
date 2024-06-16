import 'dart:io';
import 'package:archive/archive_io.dart';

// 解压
Future<bool> unzip(String gzPath, String extractPath) async {
  try {
    File compressedFile = File(gzPath);

    List<int> compressedBytes = await compressedFile.readAsBytes();

    GZipDecoder decoder = GZipDecoder();
    List<int> decompressedBytes = decoder.decodeBytes(compressedBytes);

    File decompressedFile = File(extractPath);
    await decompressedFile.writeAsBytes(decompressedBytes);

    print(gzPath + '解压完成！' + extractPath);
    return true;
  } catch (e) {
    print('解压 $gzPath 出错' + e.toString());
    return false;
  }
}

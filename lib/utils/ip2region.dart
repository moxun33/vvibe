/* // ip2region

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const int VectorIndexSize = 8;
const int VectorIndexCols = 256;
const int VectorIndexLength = 256 * 256 * (4 + 4);
const int SegmentIndexSize = 14;
final RegExp IP_REGEX = RegExp(
    r'^((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.){3}(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])$');

class Searcher {
  late String _dbFile;
  late List<int> _vectorIndex;
  List<int>? _buffer;

  Searcher(this._dbFile, this._vectorIndex, this._buffer);

  Future<Map<String, dynamic>> getStartEndPtr(
      int idx, RandomAccessFile fd, Map<String, int> ioStatus) async {
    if (_vectorIndex.isNotEmpty) {
      final sPtr = _vectorIndex
          .sublist(idx, idx + 4)
          .buffer
          .asByteData()
          .getUint32(0, Endian.little);
      final ePtr = _vectorIndex
          .sublist(idx + 4, idx + 8)
          .buffer
          .asByteData()
          .getUint32(0, Endian.little);
      return {'sPtr': sPtr, 'ePtr': ePtr};
    } else {
      final buf = await getBuffer(256 + idx, 8, fd, ioStatus);
      final sPtr = buf.buffer.asByteData().getUint32(0, Endian.little);
      final ePtr = buf.buffer.asByteData().getUint32(4, Endian.little);
      return {'sPtr': sPtr, 'ePtr': ePtr};
    }
  }

  Future<List<int>> getBuffer(int offset, int length, RandomAccessFile fd,
      Map<String, int> ioStatus) async {
    if (_buffer != null) {
      return _buffer!.sublist(offset, offset + length);
    } else {
      final buf = List<int>.filled(length, 0);
      ioStatus['ioCount'] = ioStatus['ioCount']! + 1;
      await fd.readInto(buf, 0, length, offset);
      return buf;
    }
  }

  Future<RandomAccessFile> openFilePromise() async {
    final file = File(_dbFile);
    return await file.open();
  }

  Future<Map<String, dynamic>> search(String ip) async {
    final startTime = DateTime.now().microsecondsSinceEpoch;
    final ioStatus = {'ioCount': 0};

    if (!isValidIp(ip)) {
      throw Exception('IP: $ip is invalid');
    }

    RandomAccessFile? fd;

    if (_buffer == null) {
      fd = await openFilePromise();
    }

    final ps = ip.split('.');
    final i0 = int.parse(ps[0]);
    final i1 = int.parse(ps[1]);
    final i2 = int.parse(ps[2]);
    final i3 = int.parse(ps[3]);

    final ipInt = i0 * 256 * 256 * 256 + i1 * 256 * 256 + i2 * 256 + i3;
    final idx = i0 * VectorIndexCols * VectorIndexSize + i1 * VectorIndexSize;
    final ptrMap = await getStartEndPtr(idx, fd!, ioStatus);
    final sPtr = ptrMap['sPtr']!;
    final ePtr = ptrMap['ePtr']!;
    var l = 0;
    var h = (ePtr - sPtr) ~/ SegmentIndexSize;
    String? result;

    while (l <= h) {
      final m = (l + h) >> 1;

      final p = sPtr + m * SegmentIndexSize;

      final buff = await getBuffer(p, SegmentIndexSize, fd, ioStatus);

      final sip = buff.buffer.asByteData().getUint32(0, Endian.little);

      if (ipInt < sip) {
        h = m - 1;
      } else {
        final eip = buff.buffer.asByteData().getUint32(4, Endian.little);
        if (ipInt > eip) {
          l = m + 1;
        } else {
          final dataLen = buff.buffer.asByteData().getUint16(8, Endian.little);
          final dataPtr = buff.buffer.asByteData().getUint32(10, Endian.little);

          final data =
              utf8.decode(await getBuffer(dataPtr, dataLen, fd, ioStatus));

          result = data;
          break;
        }
      }
    }
    if (fd != null) {
      await fd.close();
    }

    final diff = DateTime.now().microsecondsSinceEpoch - startTime;
    final took = diff / 1000;
    return {'region': result, 'ioCount': ioStatus['ioCount'], 'took': took};
  }
}

void _checkFile(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('$filePath does not exist');
  }
  if (!file.statSync().modeString().contains('r')) {
    throw Exception('$filePath is not readable');
  }
}

bool isValidIp(String ip) {
  return IP_REGEX.hasMatch(ip);
}

Searcher newWithFileOnly(String dbPath) {
  _checkFile(dbPath);

  return Searcher(dbPath, <int>[], null);
}

Searcher newWithVectorIndex(String dbPath, List<int> vectorIndex) {
  _checkFile(dbPath);

  if (vectorIndex.isEmpty) {
    throw Exception('vectorIndex is invalid');
  }

  return Searcher(dbPath, vectorIndex, null);
}

Searcher newWithBuffer(List<int> buffer) {
  if (buffer.isEmpty) {
    throw Exception('buffer is invalid');
  }

  return Searcher(null, null, buffer);
}

List<int> loadVectorIndexFromFile(String dbPath) {
  final file = File(dbPath);

  final fd = file.openSync();
  final buffer = List<int>.filled(VectorIndexLength, 0);
  fd.readIntoSync(buffer, 0, VectorIndexLength, 256);
  fd.closeSync();
  return buffer;
}

List<int> loadContentFromFile(String dbPath) {
  final file = File(dbPath);
  final stats = file.statSync();
  final buffer = List<int>.filled(stats.size, 0);
  final fd = file.openSync();
  fd.readIntoSync(buffer, 0, stats.size);
  fd.closeSync();
  return buffer;
}
 */
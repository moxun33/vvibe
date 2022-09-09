import 'dart:ui';

class ColorUtil {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color fromDecimal(String? num) {
    if (!(num != null && num.isNotEmpty)) return ColorUtil.fromHex('FFFFFF');
    return ColorUtil.fromHex(num.toString());
  }
}

/*
 * @Author: moxun33
 * @Date: 2022-09-09 21:59:47
 * @LastEditors: Moxx
 * @LastEditTime: 2022-11-21 15:07:51
 * @FilePath: \vvibe\lib\utils\color_util.dart
 * @Description: 
 * @qmj
 */
import 'dart:ui';

class ColorUtil {
  /// 十六进制颜色，
  /// hex, 十六进制值，例如：0xffffff,
  /// alpha, 透明度 [0.0,1.0]
  static Color hexColor(int hex, {double alpha = 1}) {
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    return Color.fromRGBO((hex & 0xFF0000) >> 16, (hex & 0x00FF00) >> 8,
        (hex & 0x0000FF) >> 0, alpha);
  }

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(
        int.parse(buffer.toString().replaceAll('0x00', '0xff'), radix: 16));
  }

//十进制转颜色
  static Color fromDecimal(String? num) {
    if (!(num != null && num.isNotEmpty)) return ColorUtil.fromHex('FFFFFF');
    return ColorUtil.fromHex(int.parse(num.toString(), radix: 16).toString());
  }
}

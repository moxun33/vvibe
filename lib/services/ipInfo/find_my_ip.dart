import 'package:vvibe/models/ip_geo.dart';
import 'package:vvibe/utils/utils.dart';

class FindMyIp {
  /**
   * @desc:   获取ip的地理位置
   * @author Moxx
   * @date 2023/11/12
   * @return {?Promise<IpGeoRes>}
   * {
   *     "code": 200,
   *     "data": {
   *         "API_1": {
   *             "ip": "175.9.143.86",
   *             "country": "中国",
   *             "province": "湖南",
   *             "city": "长沙",
   *             "county": "",
   *             "region": "亚洲",
   *             "isp": "电信"
   *         },
   *         "API_2": {
   *             "ip": "175.9.143.86",
   *             "region": "湖南省长沙市 电信"
   *         }
   *     },
   *     "processTime": "31.69ms",
   *     "url": "https://findmyip.net/",
   *     "time": "2023-12-15 19:41:51"
   * }
   */
  static Future<IpGeo?> getGeo(String ip) async {
    final res =
        await Request().get("https://findmyip.net/api/ipinfo.php", {'ip': ip});
    if (res['code'] != 200 || res['data'] == null) {
      return null;
    }
    final info = res['data']['API_1'] ?? res['data']['API_2'];
    if (info == null) return null;
    return IpGeo.fromJson(info);
  }
}

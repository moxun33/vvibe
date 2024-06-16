import 'package:ip2region_plus/ip2region_plus.dart';

class Ip2region {
  static String getGeo() {
    String dbFile = "ip2region.xdb";
    IP2RegionPlus searcher;
    try {
      searcher = IP2RegionPlus.newWithFileOnly(dbFile);
      Map region = searcher.search('8.8.8.8');
      print(region);
      return region['region'] ?? '';
    } catch (e) {
      print("failed to create searcher with '$dbFile': $e");
      return '';
    }
  }
}

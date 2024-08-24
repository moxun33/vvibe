class DanmakuType {
  static final douyu = 'douyu';
  static final douyuCN = '斗鱼';
  static final douyuGroupReg = RegExp(r'斗鱼|douyu');
  static final douyuProxyUrlReg = RegExp(r'\/dyu\/|\/douyu(\d+)?\/?(\.php)?');

  static final huya = 'huya';
  static final huyaCN = '虎牙';
  static final huyaGroupReg = RegExp(r'虎牙|huya');
  static final huyaProxyUrlReg = RegExp(r'\/hy\/|\/huya(\d+)?\/?(\.php)?');
  static final bilibili = 'bilibili';
  static final bilibiliCN = 'B站';
  static final biliGroupReg = RegExp(r'B站|bilibili');
  static final biliProxyUrlReg = RegExp(r'\/bilibili(\d+)?\/?(\.php)?');
}

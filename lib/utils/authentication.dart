import 'dart:async';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/global.dart';
import 'package:vvibe/utils/utils.dart';

/// 检查是否有 token
Future<bool> isAuthenticated() async {
  var profileJSON = LoacalStorage().getJSON(STORAGE_USER_PROFILE_KEY);
  return profileJSON != null ? true : false;
}

/// 删除缓存token
Future deleteAuthentication() async {
  await LoacalStorage().remove(STORAGE_USER_PROFILE_KEY);
  Global.profile = null;
}

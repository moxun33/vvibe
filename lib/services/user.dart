import 'package:vvibe/models/login_mode.dart';
import 'package:vvibe/utils/utils.dart';

/// 用户
class UserAPI {
  /// 登录
  static Future<UserLoginResponseModel> login({
    required Map params,
  }) async {
    var response = await Request().post(
      '/login/',
      params: params,
    );
    return UserLoginResponseModel.fromJson(response['data']);
  }
}

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:dart_ping/dart_ping.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:vvibe/common/values/consts.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';

class LimitedConnectionAdapter implements HttpClientAdapter {
  final int maxConnections;
  final HttpClientAdapter _adapter = HttpClientAdapter();

  final _lock = Lock();

  final _connections = <Uri, Completer<void>>{};

  LimitedConnectionAdapter({this.maxConnections = 5});

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    return await _lock.synchronized(() async {
      while (_connections.length > maxConnections) {
        await Future.any(_connections.values as Iterable<Future>);
      }

      final completer = Completer<void>();
      _connections[options.uri] = completer;

      try {
        return await _adapter.fetch(options, requestStream, cancelFuture);
      } finally {
        _connections.remove(options.uri);
        completer.complete();
      }
    });
  }
}

final dioCacheOptions = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),
  maxStale: const Duration(minutes: 30),
);

class PlaylistCheckReq {
  static PlaylistCheckReq _instance = PlaylistCheckReq._internal();
  factory PlaylistCheckReq() => _instance;

  late Dio dio;
  late Dio headDio;

  PlaylistCheckReq._internal() {
    dio = Dio(new BaseOptions(
        responseType: ResponseType.stream,
        headers: {
          'User-Agent': DEF_REQ_UA,
        },
        receiveTimeout: Duration(seconds: 5)));
    dio.httpClientAdapter = LimitedConnectionAdapter(maxConnections: 5);
    dio.interceptors.add(DioCacheInterceptor(options: dioCacheOptions));
    headDio = Dio(new BaseOptions(
        responseType: ResponseType.stream,
        headers: {
          'User-Agent': DEF_REQ_UA,
        },
        receiveTimeout: Duration(seconds: 10)));
    headDio.interceptors.add(DioCacheInterceptor(options: dioCacheOptions));
  }
  bool shouldGetReq(String url) {
    return url.indexOf('/udp/') > -1 ||
        url.indexOf('/rtp/') > -1 ||
        url.indexOf('/PLTV/') > -1;
  }

  Future<Map> check(String url, CancelToken cancelToken) async {
    final res = {};

    try {
      final uri = Uri.parse(url);
      final pingRes =
          await Ping(uri.host, count: 1, forceCodepage: true).stream.first;
      debugPrint('pingRes ${uri.host} $pingRes');
      if (pingRes.response?.ip == null) {
        res['status'] = 500;
      }
      res['ping'] = pingRes.response;
      /* if (shouldGetReq(url) ||
          !!PlaylistUtil().isDyHyDlProxyUrl(url)['platformHit']) {
        res['status'] = await get(url, cancelToken);
      } */
      res['status'] = await head(url, cancelToken);
    } catch (e) {
      res['status'] = 500;
    }
    return res;
  }

  Future<int> head(String url, CancelToken cancelToken) async {
    try {
      final resp = await headDio.head(url, cancelToken: cancelToken);
      return resp.statusCode ?? 500;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 422;
      debugPrint(e.toString() + url);
      return status;
    } catch (e) {
      debugPrint(e.toString());
      return 500;
    }
  }

  Future<int> get(String url, CancelToken cancelToken) async {
    try {
      int receivedBytes = 0;
      final resp = await dio.get(url, cancelToken: cancelToken);

      // 创建可读流
      final stream = resp.data.stream;

      // 循环读取流数据
      await for (List<int> value in stream) {
        // 更新已接收的字节数
        receivedBytes += value.length;
        print('====' + value.length.toString());
        // 如果超过，则取消请求
        if (receivedBytes > 1) {
          cancelToken.cancel('canceled');
          // debugPrint(url + ' 检测完成，请求已取消: ' +'字节数为 '+ receivedBytes.toString());
          break;
        }
      }
      debugPrint(url + ' 检测完成 接收字节数为 $receivedBytes  状态码：${resp.statusCode}');

      return receivedBytes > 0 ? 200 : resp.statusCode ?? 500;
    } on DioException catch (e) {
      int num = 500;
      final msg =
          (e.response?.statusMessage ?? e.message ?? e.error).toString();
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          num = 504;
          break;
        case DioExceptionType.unknown:
          num = extractStatusCode(msg, 422);
          break;
        case DioExceptionType.badResponse:
          num = extractStatusCode(msg, 400);
          break;
        default:
          break;
      }
      debugPrint('检查 可访问性出错：  $num  $msg ${e.type}  $url ');
      if (msg.indexOf('拒绝网络连接') > -1) {
        num = 500;
      }
      // 检测错误是不是因为取消请求引起的，如果是打印取消提醒
      if (CancelToken.isCancel(e)) {
        num = 200;
      }
      return num;
    } on SocketException catch (e) {
      // 网络连接错误
      debugPrint('网络连接错误: ${e.message}');
      return 500;
    } catch (e) {
      debugPrint('检查异常：$e   $url ');
      return 500;
    }
  }

  int extractStatusCode(String input, [int status = 400]) {
    if (input.indexOf('Client limit reached') > -1) return 503;
    RegExp regex = RegExp(r'\d+');
    Iterable<Match> matches = regex.allMatches(input);

    List<int> numbers =
        matches.map((match) => int.parse(match.group(0)!)).toList();
    return numbers.isNotEmpty ? numbers[0] : status;
  }
}

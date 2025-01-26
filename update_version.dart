import 'dart:io';

import 'package:yaml/yaml.dart';

void main() async {
  final file = File('pubspec.yaml');
  final content = await file.readAsString();
  final doc = loadYaml(content);

  final version = doc['version'] as String;
  final versionParts = version.split('.');

  // 你可以根据需要更新版本的哪个部分
  // 以下是更新修订版本（即版本号的第三部分）
  versionParts[2] = (int.parse(versionParts[2]) + 1).toString(); // 增加修订版本

  // 重新组装版本号
  final newVersion = '${versionParts[0]}.${versionParts[1]}.${versionParts[2]}';

  // 更新 pubspec.yaml 文件中的版本号
  final newContent = content.replaceFirst(version, newVersion);
  await file.writeAsString(newContent);

  print('Updated version: $newVersion');
}
// dart run update_version.dart

# vvibe

<img width="100" alt="image" src="https://raw.githubusercontent.com/moxun33/vvibe/main/assets/logo.png?token=GHSAT0AAAAAABRX4K3QRU76NHLPZDLZ2JWSYY67OQA">

![img](https://img.shields.io/badge/language-dart-blue.svg?style=for-the-badge&color=00ACC1)
![img](https://img.shields.io/badge/flutter-00B0FF?style=for-the-badge&logo=flutter)
[![img](https://img.shields.io/github/downloads/moxun33/vvibe/total?style=for-the-badge&color=ac30fe)](https://github.com/moxun33/vvibe/releases)
![img](https://img.shields.io/github/license/moxun33/vvibe?style=for-the-badge)
![img](https://img.shields.io/github/stars/moxun33/vvibe?style=for-the-badge)
![img](https://img.shields.io/github/issues/moxun33/vvibe?style=for-the-badge&color=9C27B0)

> 自用的视频直播观看软件

## 功能

- 播放本地文件``m3u``或``txt``播放列表
- 订阅远程``m3u``或``txt``播放列表
- 支持``虎牙``，``斗鱼``和``哔哩哔哩``的实时弹幕 （请确保m3u文件的group-title分别为斗鱼或douyu、虎牙或huya、 B站或bilibili, tvg-id为真实房间id）
- 播放列表管理，分组、搜索
  
## 多平台

    目前仅支持windows，暂无其他平台支持计划

## 开发

- 拉取项目，安装依赖

- (可选) FFI Code Gen ，运行

``flutter_rust_bridge_codegen  --rust-input rust/src/api.rs  --dart-output lib/bridge_generated.dart --skip-deps-check``

- 启动项目

## 截图

![img](https://raw.githubusercontent.com/moxun33/vvibe/main/screenshots/player.png)

![img](https://raw.githubusercontent.com/moxun33/vvibe/main/screenshots/settings.png)

## 注意

1、有些包不支持 safety模式。解决方案：``--no-sound-null-safety``

- run
``flutter run --no-sound-null-safety``
- build
``flutter build apk --no-sound-null-safety``

2、由于``dart_vlc``的``ffi``版本与``flutter-rust_bridge``的``ffi``版本冲突，目前强制使用``ffi 2.x``版本

3、本应用不内置播放源，请自行准备直播源(源代码playlist目录中播放源仅供开发测试，请勿用于其他途径)

4、直播平台播放源的解析可参考 [real-url](https://github.com/moxun33/real-url)  , 可自行搭建服务器定时解析，推荐使用[青龙](https://github.com/whyour/qinglong)，``虎牙``，``斗鱼``和``哔哩哔哩``的直播源解析的青龙脚本 [ql-scripts](https://github.com/moxun33/ql-scripts)

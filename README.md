# vvibe

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flutter Rust Bridge

### Requirements

- ``dart pub global activate ffigen``
- ``cargo install flutter_rust_bridge_codegen``  
- See [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- See [ffigen](https://pub.dev/packages/ffigen)

### FFI Code Gen

run

``flutter_rust_bridge_codegen  --rust-input rust/src/api.rs  --dart-output lib/bridge_generated.dart --skip-deps-check``

# 注意

有些包不支持 safety模式。

解决方案：``--no-sound-null-safety``

- run
``flutter run --no-sound-null-safety``
- build
``flutter build apk --no-sound-null-safety``

# ip2region_ffi

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

The plugin project was generated without specifying the `--platforms` flag, no platforms are currently supported.
To add platforms, run `flutter create -t plugin --platforms <platforms> .` in this directory.
You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at [plugin platforms](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms).

## Requirements

- ``dart pub global activate ffigen``
- ``cargo install flutter_rust_bridge_codegen``  
- See [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- See [ffigen](https://pub.dev/packages/ffigen)

## Code Gen

run ``flutter_rust_bridge_codegen  --rust-input rust/src/api.rs  --dart-output lib/bridge_generated.dart --skip-deps-check`` in ``packages/ip2region_ffi``  

- ``--skip-deps-check`` option is required. Because the version of ``ffi`` from``dart_vlc_ffi`` is incompatible with ``ip2region_ffi``. Have to downgrade version of ``ffi`` in``ip2region_ffi``. more details in ``packages/ip2region_ffi`` ``pubsepec.yaml``

## IP Database

copy ``rust/ip2region.xdb`` to the flutter assets dir.

#ifndef FLUTTER_PLUGIN_IP2REGION_FFI_PLUGIN_H_
#define FLUTTER_PLUGIN_IP2REGION_FFI_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ip2region_ffi {

class Ip2regionFfiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  Ip2regionFfiPlugin();

  virtual ~Ip2regionFfiPlugin();

  // Disallow copy and assign.
  Ip2regionFfiPlugin(const Ip2regionFfiPlugin&) = delete;
  Ip2regionFfiPlugin& operator=(const Ip2regionFfiPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ip2region_ffi

#endif  // FLUTTER_PLUGIN_IP2REGION_FFI_PLUGIN_H_

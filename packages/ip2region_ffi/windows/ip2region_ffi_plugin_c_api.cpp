#include "include/ip2region_ffi/ip2region_ffi_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ip2region_ffi_plugin.h"

void Ip2regionFfiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ip2region_ffi::Ip2regionFfiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

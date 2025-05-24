#include "include/sqlbase/sqlbase_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "sqlbase_plugin.h"

void SqlbasePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  sqlbase::SqlbasePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

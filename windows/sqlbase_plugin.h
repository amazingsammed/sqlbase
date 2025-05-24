#ifndef FLUTTER_PLUGIN_SQLBASE_PLUGIN_H_
#define FLUTTER_PLUGIN_SQLBASE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace sqlbase {

class SqlbasePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SqlbasePlugin();

  virtual ~SqlbasePlugin();

  // Disallow copy and assign.
  SqlbasePlugin(const SqlbasePlugin&) = delete;
  SqlbasePlugin& operator=(const SqlbasePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace sqlbase

#endif  // FLUTTER_PLUGIN_SQLBASE_PLUGIN_H_

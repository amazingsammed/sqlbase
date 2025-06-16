import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sqlbase_method_channel.dart';

abstract class SqlbasePlatform extends PlatformInterface {
  /// Constructs a SqlbasePlatform.
  SqlbasePlatform() : super(token: _token);

  static final Object _token = Object();

  static SqlbasePlatform _instance = MethodChannelSqlbase();

  /// The default instance of [SqlbasePlatform] to use.
  ///
  /// Defaults to [MethodChannelSqlbase].
  static SqlbasePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SqlbasePlatform] when
  /// they register themselves.
  static set instance(SqlbasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

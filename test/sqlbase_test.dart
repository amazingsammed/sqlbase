import 'package:flutter_test/flutter_test.dart';
import 'package:sqlbase/sqlbase.dart';
import 'package:sqlbase/sqlbase_platform_interface.dart';
import 'package:sqlbase/sqlbase_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSqlbasePlatform
    with MockPlatformInterfaceMixin
    implements SqlbasePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SqlbasePlatform initialPlatform = SqlbasePlatform.instance;

  test('$MethodChannelSqlbase is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSqlbase>());
  });

  test('getPlatformVersion', () async {
    Sqlbase sqlbasePlugin = Sqlbase();
    MockSqlbasePlatform fakePlatform = MockSqlbasePlatform();
    SqlbasePlatform.instance = fakePlatform;

    expect(await sqlbasePlugin.getPlatformVersion(), '42');
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ali_iot_plugin/src/ali_iot_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('ali_iot_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await AliIotPlugin.platformVersion, '42');
  });
}

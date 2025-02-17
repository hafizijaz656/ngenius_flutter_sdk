import 'package:flutter_test/flutter_test.dart';
import 'package:ngenius_flutter_sdk/ngenius_flutter_sdk.dart';
import 'package:ngenius_flutter_sdk/ngenius_flutter_sdk_platform_interface.dart';
import 'package:ngenius_flutter_sdk/ngenius_flutter_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNgeniusFlutterSdkPlatform
    with MockPlatformInterfaceMixin
    implements NgeniusFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NgeniusFlutterSdkPlatform initialPlatform = NgeniusFlutterSdkPlatform.instance;

  test('$MethodChannelNgeniusFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNgeniusFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    NgeniusFlutterSdk ngeniusFlutterSdkPlugin = NgeniusFlutterSdk();
    MockNgeniusFlutterSdkPlatform fakePlatform = MockNgeniusFlutterSdkPlatform();
    NgeniusFlutterSdkPlatform.instance = fakePlatform;

    expect(await ngeniusFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}

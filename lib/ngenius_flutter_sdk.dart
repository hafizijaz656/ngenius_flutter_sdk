import 'package:ngenius_flutter_sdk/ngenius_response_model.dart';

import 'ngenius_flutter_sdk_platform_interface.dart';

class NgeniusFlutterSdk {
  Future<NGeniusResponseModel> launchCardPayment(
      {required Map<String, dynamic> orderJsonObject}) {
    return NgeniusFlutterSdkPlatform.instance
        .launchCardPayment(orderJsonObject: orderJsonObject);
  }
}

import 'package:ably_flutter_example/app_provisioning.dart';
import 'package:ably_flutter_example/constants.dart';

class ApiKeyService {
  static const envKey = String.fromEnvironment(Constants.ablyApiKey);
  static const defaultEnvKeyPlaceholder = 'replace_with_your_api_key';

  Future<ApiKeyProvision> getOrProvisionApiKey() async {
    if (envKey.isNotEmpty && envKey != defaultEnvKeyPlaceholder) {
      return ApiKeyProvision(
        key: envKey,
        source: ApiKeySource.env,
      );
    } else {
      final provisionedKey = await AppProvisioning().provisionApp();
      return ApiKeyProvision(
        key: provisionedKey,
        source: ApiKeySource.testProvision,
      );
    }
  }
}

class ApiKeyProvision {
  String key;

  ApiKeySource source;

  ApiKeyProvision({
    required this.key,
    required this.source,
  });
}

enum ApiKeySource {
  env,
  testProvision,
}

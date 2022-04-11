import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/ui/api_key_service.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SystemDetailsSliver extends HookWidget {
  ApiKeyProvision apiKeyProvision;

  SystemDetailsSliver(this.apiKeyProvision);

  @override
  Widget build(BuildContext context) {
    final platformVersion = useState<String?>(null);
    final ablyVersion = useState<String?>(null);

    useEffect(() {
      ably.platformVersion().then((version) => platformVersion.value = version);
      ably.version().then((version) => ablyVersion.value = version);
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        TextRow('Running on', platformVersion.value),
        TextRow('Ably version', ablyVersion.value),
        TextRow('Ably Client ID', Constants.clientId),
        TextRow('Ably API key', hideApiKeySecret(apiKeyProvision.key)),
        if (apiKeyProvision.source != ApiKeySource.env)
          RichText(
            text: const TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: 'Warning: ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: 'Ably API key is not configured! Application uses '
                        'auto-provisioned sandbox key. Please follow '
                        'instructions in the repository Readme file to '
                        'setup the sample with your API key.',
                  )
                ]),
          ),
      ],
    );
  }

  String hideApiKeySecret(String apiKey) {
    // What is an API Key?: https://faqs.ably.com/what-is-an-app-api-key
    final keyComponents = apiKey.split(':');
    if (keyComponents.length != 2) {
      return apiKey;
    }
    final publicApiKey = keyComponents[0];
    final apiKeySecret = keyComponents[1];
    return '$publicApiKey:${'*' * apiKeySecret.length}';
  }
}

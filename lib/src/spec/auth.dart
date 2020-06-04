import 'common.dart';
import 'rest/options.dart';


class AuthBase {
  String clientId;
}

abstract class Auth extends AuthBase {
  Future<TokenDetails> authorize({
    TokenParams tokenParams,
    AuthOptions authOptions
  });
  Future<TokenRequest> createTokenRequest({
    TokenParams tokenParams,
    AuthOptions authOptions
  });
  Future<TokenDetails> requestToken({
    TokenParams tokenParams,
    AuthOptions authOptions
  });
}

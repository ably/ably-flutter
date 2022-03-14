class EncryptedMessageData {
  static String key128bit = 'WUP6u0K7MXI5Zeo0VppPwg==';

  static List<TestMessagePair> crypto128 = [
    TestMessagePair(
      encoded: '''{
        "name": "example",
        "data": "The quick brown fox jumped over the lazy dog"
      }''',
      encrypted: '''{
        "name": "example",
        "data":
            "HO4cYSP8LybPYBPZPHQOtmHItcxYdSvcNUC6kXVpMn0VFL+9z2/5tJ6WFbR0SBT1xhFRuJ+MeBGTU3yOY9P5ow==",
        "encoding": "utf-8/cipher+aes-128-cbc/base64"
      }''',
    ),
    TestMessagePair(
      encoded: '''{
        "name": "example",
        "data": "AAECAwQFBgcICQoLDA0ODw==",
        "encoding": "base64"
      }''',
      encrypted: '''{
        "name": "example",
        "data":
            "HO4cYSP8LybPYBPZPHQOtuB3dfKG08yw7J4qx3kkjxdW0eoZv+nGAp76OKqYQ327",
        "encoding": "cipher+aes-128-cbc/base64"
      }''',
    ),
    // FIXME: JSON like this breaks ably-java
    // See: https://github.com/ably/ably-java/issues/752
    /*TestMessagePair(
      encoded: '''{
        "name": "example",
        "data": {"example":{"json":"Object"}},
        "encoding": "json"
      }''',
      encrypted: '''{
        "name": "example",
        "data":
            "HO4cYSP8LybPYBPZPHQOtuD53yrD3YV3NBoTEYBh4U0N1QXHbtkfsDfTspKeLQFt",
        "encoding": "json/utf-8/cipher+aes-128-cbc/base64"
      }''', 
    ),*/
    // TestMessagePair(
    //   encoded: '''{
    //     "name": "example",
    //     "data": ["example","json","array"],
    //     "encoding": "json"
    //   }''',
    //   encrypted: '''{
    //     "name": "example",
    //     "data":
    //         "HO4cYSP8LybPYBPZPHQOtvmStzmExkdjvrn51J6cmaTZrGl+EsJ61sgxmZ6j6jcA",
    //     "encoding": "json/utf-8/cipher+aes-128-cbc/base64"
    //   }''',
    // )
  ];
}

class TestMessagePair {
  String encoded;

  String encrypted;

  TestMessagePair({
    required this.encoded,
    required this.encrypted,
  });
}

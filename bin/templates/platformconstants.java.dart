String $(c) {
  return '''
package io.ably.flutter.plugin.gen;


public class PlatformConstants{

  public class CodecTypes {
    ${c['types'].map((_) => 'public static final byte ${_['name']} = (byte)${_['value']};').join('\n\t')}
  }

  public class PlatformMethod {
    ${c['methods'].map((_) => 'public static final String ${_['name']} = "${_['value']}";').join('\n\t')}
  }
  
${c['objects'].map((_) {
      return '''
  public class Tx${_['name']}{
    ${_['properties'].map((_p) => 'public static final String ${_p} = "${_p}";').join('\n\t')}
  }''';
    }).join('\n')}
}
''';
}

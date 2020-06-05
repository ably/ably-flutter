String $(c) {
  return '''
package io.ably.flutter.plugin.generated;


final public class PlatformConstants{

  final public class CodecTypes {
    ${c['types'].map((_) => 'public static final byte ${_['name']} = (byte)${_['value']};').join('\n\t')}
  }

  final public class PlatformMethod {
    ${c['methods'].map((_) => 'public static final String ${_['name']} = "${_['value']}";').join('\n\t')}
  }
  
${c['objects'].map((_) {
      return '''
  final public class Tx${_['name']}{
    ${_['properties'].map((_p) => 'public static final String ${_p} = "${_p}";').join('\n\t')}
  }''';
    }).join('\n')}
}
''';
}

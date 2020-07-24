String $(c) {
  return '''
package io.ably.flutter.plugin.generated;


final public class PlatformConstants{

\tfinal public class CodecTypes {
\t\t${c['types'].map((_) => 'public static final byte ${_['name']} = (byte)${_['value']};').join('\n\t\t')}
\t}

\tfinal public class PlatformMethod {
\t\t${c['methods'].map((_) => 'public static final String ${_['name']} = "${_['value']}";').join('\n\t\t')}
\t}
  
${c['objects'].map((_) {
      return '''
\tfinal public class Tx${_['name']}{
\t\t${_['properties'].map((_p) => 'public static final String ${_p} = "${_p}";').join('\n\t\t')}
\t}
''';
    }).join('\n')}
}
''';
}

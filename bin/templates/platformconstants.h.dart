String $(Map<String, dynamic> c) => '''
@import Foundation;

typedef NS_ENUM(UInt8, CodecType) {
\t${c['types'].map((_) => 'CodecType${_capitalize(_['name'] as String)} = ${_['value']},').join('\n\t')}
};


// flutter platform channel method names
${c['methods'].map((_) => 'extern NSString *const AblyPlatformMethod_${_['name']};').join('\n')}

${c['objects'].map((_) => '''
// key constants for ${_['name']}
${_['properties'].map((name) => 'extern NSString *const Tx${_['name']}_$name;').join('\n')}
''').join('\n')}''';

String _capitalize(String sentence) {
  return "${sentence[0].toUpperCase()}${sentence.substring(1)}";
}

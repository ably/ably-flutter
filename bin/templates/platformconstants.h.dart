String $(Map<String, dynamic> c) => '''
@import Foundation;

typedef NS_ENUM(UInt8, _Value) {
\t${c['types'].map((_) => '${_['name']}CodecType = ${_['value']},').join('\n\t')}
};


// flutter platform channel method names
${c['methods'].map((_) => 'extern NSString *const AblyPlatformMethod_${_['name']};').join('\n')}

${c['objects'].map((_) => '''
// key constants for ${_['name']}
${_['properties'].map((name) => 'extern NSString *const Tx${_['name']}_$name;').join('\n')}
''').join('\n')}''';

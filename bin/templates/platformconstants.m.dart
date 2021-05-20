String $(Map<String, dynamic> c) => '''
#import "AblyPlatformConstants.h"


// flutter platform channel method names
${c['methods'].map((_) => 'NSString *const AblyPlatformMethod_${_['name']}= @"${_['value']}";').join('\n')}

${c['objects'].map((_) => '''
// key constants for ${_['name']}
${_['properties'].map((name) => 'NSString *const Tx${_['name']}_$name = @"$name";').join('\n')}
''').join('\n')}''';

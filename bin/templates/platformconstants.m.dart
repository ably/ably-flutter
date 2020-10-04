String $(c) {
  return '''
#import "AblyPlatformConstants.h"


@implementation AblyPlatformMethod
${c['methods'].map((_) => 'NSString *const AblyPlatformMethod_${_['name']}= @"${_['value']}";').join('\n')}
@end

${c['objects'].map((_) {
    return '''
@implementation Tx${_['name']}
${_['properties'].map((name) => 'NSString *const Tx${_['name']}_$name = @"$name";').join('\n')}
@end
''';
  }).join('\n')}''';
}

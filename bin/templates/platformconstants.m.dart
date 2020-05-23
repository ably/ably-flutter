String $(c) {
  return '''
#import <Foundation/Foundation.h>
#import "AblyPlatformConstants.h"


@implementation AblyPlatformMethod
${c['methods'].map((_) => '+ (NSString*) ${_['name']} { return @"${_['value']}"; }').join('\n')}
@end

${c['objects'].map((_) {
    return '''
@implementation Tx${_['name']}
${_['properties'].map((_) => '+ (NSString*) ${_} { return @"${_}"; }').join('\n')}
@end
''';
  }).join('\n')}''';
}
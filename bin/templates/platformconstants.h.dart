String $(c) {
  return '''
#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, _Value) {
  ${c['types'].map((_) => '${_['name']}CodecType = ${_['value']},').join('\n  ')}
};


@interface AblyPlatformMethod : NSObject
${c['methods'].map((_) => '@property (class, nonatomic, assign, readonly) NSString *${_['name']};').join('\n')}
@end

${c['objects'].map((_) {
    return '''
@interface Tx${_['name']} : NSObject
${_['properties'].map((_) => '@property (class, nonatomic, assign, readonly) NSString *${_};').join('\n')}
@end
''';
  }).join('\n')}''';
}
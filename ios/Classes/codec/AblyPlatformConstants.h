//
// Generated code. Do not modify.
// source: bin/templates/platformconstants.h.hbs 
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, _Value) {

  ablyMessageCodecType = 128,
  clientOptionsCodecType = 129,
  errorInfoCodecType = 144,
  connectionStateChangeCodecType = 201,
  channelStateChangeCodecType = 202,
  
};


@interface AblyPlatformMethod : NSObject

@property (class, nonatomic, assign, readonly) NSString *getPlatformVersion;
@property (class, nonatomic, assign, readonly) NSString *getVersion;
@property (class, nonatomic, assign, readonly) NSString *registerAbly;
@property (class, nonatomic, assign, readonly) NSString *createRestWithOptions;
@property (class, nonatomic, assign, readonly) NSString *publish;
@property (class, nonatomic, assign, readonly) NSString *createRealtimeWithOptions;
@property (class, nonatomic, assign, readonly) NSString *connectRealtime;
@property (class, nonatomic, assign, readonly) NSString *closeRealtime;
@property (class, nonatomic, assign, readonly) NSString *onRealtimeConnectionStateChanged;
@property (class, nonatomic, assign, readonly) NSString *onRealtimeChannelStateChanged;

@end

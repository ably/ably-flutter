//
// Generated code. Do not modify.
// source: bin/templates/platformconstants.h.hbs 
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, _Value) {

  codecTypes_ablyMessage = 128,
  codecTypes_clientOptions = 129,
  codecTypes_tokenDetails = 130,
  codecTypes_errorInfo = 144,
  codecTypes_connectionEvent = 201,
  codecTypes_connectionState = 202,
  codecTypes_connectionStateChange = 203,
  codecTypes_channelEvent = 204,
  codecTypes_channelState = 205,
  codecTypes_channelStateChange = 206,
  
};


@interface PLATFORM_METHODS : NSObject

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

@import Foundation;
@import Flutter;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterReader : FlutterStandardReader
@end

NS_ASSUME_NONNULL_END


typedef NS_ENUM(UInt8, _Value) {
    //Ably flutter plugin protocol message
    _valueAblyMessage = 128,
    
    //Other ably objects
    _valueClientOptions = 129,
    _valueTokenDetails = 130,
    _ValueErrorInfo = 144,
    
    //Events
    _connectionEvent = 201,
    _connectionState = 202,
    _connectionStateChange = 203,
    _channelEvent = 204,
    _channelState = 205,
    _channelStateChange = 206,
};

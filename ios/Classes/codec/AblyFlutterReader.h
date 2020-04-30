@import Foundation;
@import Flutter;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterReader : FlutterStandardReader
@end

NS_ASSUME_NONNULL_END


typedef NS_ENUM(UInt8, _Value) {
    _valueClientOptions = 128,
    _valueTokenDetails = 129,
    _ValueErrorInfo = 144,
    _valueAblyMessage = 255,
};

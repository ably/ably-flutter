// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: datatypes.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum CodecDataType

/**
 * Custom type values must be over 127. At the time of writing the standard message
 * codec encodes them as an unsigned byte which means the maximum type value is 255.
 * If we get to the point of having more than that number of custom types (i.e. more
 * than 128 [255 - 127]) then we can either roll our own codec from scratch or,
 * perhaps easier, reserve custom type value 255 to indicate that it will be followed
 * by a subtype value - perhaps of a wider type.
 *
 * https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
 **/
typedef GPB_ENUM(CodecDataType) {
  /**
   * Value used if any message's field encounters a value that is not defined
   * by this enum. The message will also have C functions to get/set the rawValue
   * of the field.
   **/
  CodecDataType_GPBUnrecognizedEnumeratorValue = kGPBUnrecognizedEnumeratorValue,
  /** this can't be avoided as first enum value must be 0 in proto3 */
  CodecDataType_Zero = 0,

  /** Ably flutter plugin protocol message */
  CodecDataType_AblyMessage = 128,

  /** Other ably objects */
  CodecDataType_ClientOptions = 129,
  CodecDataType_TokenDetails = 130,
  CodecDataType_ErrorInfo = 144,

  /** Events */
  CodecDataType_ConnectionEvent = 201,
  CodecDataType_ConnectionState = 202,
  CodecDataType_ConnectionStateChange = 203,
  CodecDataType_ChannelEvent = 204,
  CodecDataType_ChannelState = 205,
  CodecDataType_ChannelStateChange = 206,
};

GPBEnumDescriptor *CodecDataType_EnumDescriptor(void);

/**
 * Checks to see if the given value is defined by the enum or was not known at
 * the time this source was generated.
 **/
BOOL CodecDataType_IsValidValue(int32_t value);

#pragma mark - DatatypesRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface DatatypesRoot : GPBRootObject
@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

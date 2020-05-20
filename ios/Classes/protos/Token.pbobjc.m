// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: token.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "Token.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - TokenRoot

@implementation TokenRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - TokenRoot_FileDescriptor

static GPBFileDescriptor *TokenRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - TokenDetails

@implementation TokenDetails

@dynamic token;
@dynamic expires;
@dynamic issued;
@dynamic capability;
@dynamic clientId;

typedef struct TokenDetails__storage_ {
  uint32_t _has_storage_[1];
  uint32_t expires;
  uint32_t issued;
  NSString *token;
  NSString *capability;
  NSString *clientId;
} TokenDetails__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "token",
        .dataTypeSpecific.className = NULL,
        .number = TokenDetails_FieldNumber_Token,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(TokenDetails__storage_, token),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "expires",
        .dataTypeSpecific.className = NULL,
        .number = TokenDetails_FieldNumber_Expires,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(TokenDetails__storage_, expires),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "issued",
        .dataTypeSpecific.className = NULL,
        .number = TokenDetails_FieldNumber_Issued,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(TokenDetails__storage_, issued),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
      {
        .name = "capability",
        .dataTypeSpecific.className = NULL,
        .number = TokenDetails_FieldNumber_Capability,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(TokenDetails__storage_, capability),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "clientId",
        .dataTypeSpecific.className = NULL,
        .number = TokenDetails_FieldNumber_ClientId,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(TokenDetails__storage_, clientId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[TokenDetails class]
                                     rootClass:[TokenRoot class]
                                          file:TokenRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(TokenDetails__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\005\010\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - TokenParams

@implementation TokenParams

@dynamic capability;
@dynamic clientId;
@dynamic nonce;
@dynamic hasTimestamp, timestamp;
@dynamic ttl;

typedef struct TokenParams__storage_ {
  uint32_t _has_storage_[1];
  uint32_t ttl;
  NSString *capability;
  NSString *clientId;
  NSString *nonce;
  GPBTimestamp *timestamp;
} TokenParams__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "capability",
        .dataTypeSpecific.className = NULL,
        .number = TokenParams_FieldNumber_Capability,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(TokenParams__storage_, capability),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "clientId",
        .dataTypeSpecific.className = NULL,
        .number = TokenParams_FieldNumber_ClientId,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(TokenParams__storage_, clientId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "nonce",
        .dataTypeSpecific.className = NULL,
        .number = TokenParams_FieldNumber_Nonce,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(TokenParams__storage_, nonce),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "timestamp",
        .dataTypeSpecific.className = GPBStringifySymbol(GPBTimestamp),
        .number = TokenParams_FieldNumber_Timestamp,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(TokenParams__storage_, timestamp),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "ttl",
        .dataTypeSpecific.className = NULL,
        .number = TokenParams_FieldNumber_Ttl,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(TokenParams__storage_, ttl),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeUInt32,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[TokenParams class]
                                     rootClass:[TokenRoot class]
                                          file:TokenRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(TokenParams__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\002\010\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

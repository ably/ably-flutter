///
//  Generated code. Do not modify.
//  source: datatypes.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class CodecDataType extends $pb.ProtobufEnum {
  static const CodecDataType ZERO____ = CodecDataType._(0, '__ZERO__');
  static const CodecDataType ABLY_MESSAGE = CodecDataType._(128, 'ABLY_MESSAGE');
  static const CodecDataType CLIENT_OPTIONS = CodecDataType._(129, 'CLIENT_OPTIONS');
  static const CodecDataType TOKEN_DETAILS = CodecDataType._(130, 'TOKEN_DETAILS');
  static const CodecDataType ERROR_INFO = CodecDataType._(144, 'ERROR_INFO');
  static const CodecDataType CONNECTION_EVENT = CodecDataType._(201, 'CONNECTION_EVENT');
  static const CodecDataType CONNECTION_STATE = CodecDataType._(202, 'CONNECTION_STATE');
  static const CodecDataType CONNECTION_STATE_CHANGE = CodecDataType._(203, 'CONNECTION_STATE_CHANGE');
  static const CodecDataType CHANNEL_EVENT = CodecDataType._(204, 'CHANNEL_EVENT');
  static const CodecDataType CHANNEL_STATE = CodecDataType._(205, 'CHANNEL_STATE');
  static const CodecDataType CHANNEL_STATE_CHANGE = CodecDataType._(206, 'CHANNEL_STATE_CHANGE');

  static const $core.List<CodecDataType> values = <CodecDataType> [
    ZERO____,
    ABLY_MESSAGE,
    CLIENT_OPTIONS,
    TOKEN_DETAILS,
    ERROR_INFO,
    CONNECTION_EVENT,
    CONNECTION_STATE,
    CONNECTION_STATE_CHANGE,
    CHANNEL_EVENT,
    CHANNEL_STATE,
    CHANNEL_STATE_CHANGE,
  ];

  static final $core.Map<$core.int, CodecDataType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CodecDataType valueOf($core.int value) => _byValue[value];

  const CodecDataType._($core.int v, $core.String n) : super(v, n);
}


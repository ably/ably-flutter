///
//  Generated code. Do not modify.
//  source: clientoptions.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class HTTPMethods extends $pb.ProtobufEnum {
  static const HTTPMethods POST = HTTPMethods._(0, 'POST');
  static const HTTPMethods GET = HTTPMethods._(1, 'GET');

  static const $core.List<HTTPMethods> values = <HTTPMethods> [
    POST,
    GET,
  ];

  static final $core.Map<$core.int, HTTPMethods> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HTTPMethods valueOf($core.int value) => _byValue[value];

  const HTTPMethods._($core.int v, $core.String n) : super(v, n);
}


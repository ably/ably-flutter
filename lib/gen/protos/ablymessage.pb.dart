///
//  Generated code. Do not modify.
//  source: ablymessage.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/struct.pb.dart' as $0;

import 'datatypes.pbenum.dart' as $1;

class AblyMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('AblyMessage', createEmptyInstance: create)
    ..aInt64(1, 'registrationHandle', protoName: 'registrationHandle')
    ..e<$1.CodecDataType>(2, 'messageType', $pb.PbFieldType.OE, protoName: 'messageType', defaultOrMaker: $1.CodecDataType.ZERO____, valueOf: $1.CodecDataType.valueOf, enumValues: $1.CodecDataType.values)
    ..aOM<$0.Struct>(3, 'message', subBuilder: $0.Struct.create)
    ..hasRequiredFields = false
  ;

  AblyMessage._() : super();
  factory AblyMessage() => create();
  factory AblyMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AblyMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  AblyMessage clone() => AblyMessage()..mergeFromMessage(this);
  AblyMessage copyWith(void Function(AblyMessage) updates) => super.copyWith((message) => updates(message as AblyMessage));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AblyMessage create() => AblyMessage._();
  AblyMessage createEmptyInstance() => create();
  static $pb.PbList<AblyMessage> createRepeated() => $pb.PbList<AblyMessage>();
  @$core.pragma('dart2js:noInline')
  static AblyMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AblyMessage>(create);
  static AblyMessage _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get registrationHandle => $_getI64(0);
  @$pb.TagNumber(1)
  set registrationHandle($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRegistrationHandle() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationHandle() => clearField(1);

  @$pb.TagNumber(2)
  $1.CodecDataType get messageType => $_getN(1);
  @$pb.TagNumber(2)
  set messageType($1.CodecDataType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageType() => clearField(2);

  @$pb.TagNumber(3)
  $0.Struct get message => $_getN(2);
  @$pb.TagNumber(3)
  set message($0.Struct v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);
  @$pb.TagNumber(3)
  $0.Struct ensureMessage() => $_ensure(2);
}


///
//  Generated code. Do not modify.
//  source: token.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $2;

class TokenDetails extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TokenDetails', createEmptyInstance: create)
    ..aOS(1, 'token')
    ..a<$core.int>(2, 'expires', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, 'issued', $pb.PbFieldType.OU3)
    ..aOS(4, 'capability')
    ..aOS(5, 'clientId', protoName: 'clientId')
    ..hasRequiredFields = false
  ;

  TokenDetails._() : super();
  factory TokenDetails() => create();
  factory TokenDetails.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenDetails.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TokenDetails clone() => TokenDetails()..mergeFromMessage(this);
  TokenDetails copyWith(void Function(TokenDetails) updates) => super.copyWith((message) => updates(message as TokenDetails));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TokenDetails create() => TokenDetails._();
  TokenDetails createEmptyInstance() => create();
  static $pb.PbList<TokenDetails> createRepeated() => $pb.PbList<TokenDetails>();
  @$core.pragma('dart2js:noInline')
  static TokenDetails getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenDetails>(create);
  static TokenDetails _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get expires => $_getIZ(1);
  @$pb.TagNumber(2)
  set expires($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasExpires() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpires() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get issued => $_getIZ(2);
  @$pb.TagNumber(3)
  set issued($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIssued() => $_has(2);
  @$pb.TagNumber(3)
  void clearIssued() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get capability => $_getSZ(3);
  @$pb.TagNumber(4)
  set capability($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCapability() => $_has(3);
  @$pb.TagNumber(4)
  void clearCapability() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => clearField(5);
}

class TokenParams extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TokenParams', createEmptyInstance: create)
    ..aOS(1, 'capability')
    ..aOS(2, 'clientId', protoName: 'clientId')
    ..aOS(3, 'nonce')
    ..aOM<$2.Timestamp>(4, 'timestamp', subBuilder: $2.Timestamp.create)
    ..a<$core.int>(5, 'ttl', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  TokenParams._() : super();
  factory TokenParams() => create();
  factory TokenParams.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenParams.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TokenParams clone() => TokenParams()..mergeFromMessage(this);
  TokenParams copyWith(void Function(TokenParams) updates) => super.copyWith((message) => updates(message as TokenParams));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TokenParams create() => TokenParams._();
  TokenParams createEmptyInstance() => create();
  static $pb.PbList<TokenParams> createRepeated() => $pb.PbList<TokenParams>();
  @$core.pragma('dart2js:noInline')
  static TokenParams getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenParams>(create);
  static TokenParams _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get capability => $_getSZ(0);
  @$pb.TagNumber(1)
  set capability($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCapability() => $_has(0);
  @$pb.TagNumber(1)
  void clearCapability() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get nonce => $_getSZ(2);
  @$pb.TagNumber(3)
  set nonce($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNonce() => $_has(2);
  @$pb.TagNumber(3)
  void clearNonce() => clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($2.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get ttl => $_getIZ(4);
  @$pb.TagNumber(5)
  set ttl($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTtl() => $_has(4);
  @$pb.TagNumber(5)
  void clearTtl() => clearField(5);
}


///
//  Generated code. Do not modify.
//  source: clientoptions.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'token.pb.dart' as $3;

import 'clientoptions.pbenum.dart';

export 'clientoptions.pbenum.dart';

class ClientOptions extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ClientOptions', createEmptyInstance: create)
    ..aOS(1, 'authUrl', protoName: 'authUrl')
    ..e<HTTPMethods>(2, 'authMethod', $pb.PbFieldType.OE, protoName: 'authMethod', defaultOrMaker: HTTPMethods.POST, valueOf: HTTPMethods.valueOf, enumValues: HTTPMethods.values)
    ..aOS(3, 'key')
    ..aOM<$3.TokenDetails>(4, 'tokenDetails', protoName: 'tokenDetails', subBuilder: $3.TokenDetails.create)
    ..m<$core.String, $core.String>(5, 'authHeaders', protoName: 'authHeaders', entryClassName: 'ClientOptions.AuthHeadersEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS)
    ..m<$core.String, $core.String>(6, 'authParams', protoName: 'authParams', entryClassName: 'ClientOptions.AuthParamsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS)
    ..aOB(7, 'queryTime', protoName: 'queryTime')
    ..aOB(8, 'useTokenAuth', protoName: 'useTokenAuth')
    ..aOS(9, 'clientId', protoName: 'clientId')
    ..a<$core.int>(10, 'logLevel', $pb.PbFieldType.O3, protoName: 'logLevel')
    ..aOB(11, 'tls')
    ..aOS(12, 'restHost', protoName: 'restHost')
    ..aOS(13, 'realtimeHost', protoName: 'realtimeHost')
    ..a<$core.int>(14, 'port', $pb.PbFieldType.OU3)
    ..a<$core.int>(15, 'tlsPort', $pb.PbFieldType.OU3, protoName: 'tlsPort')
    ..aOB(16, 'autoConnect', protoName: 'autoConnect')
    ..aOB(17, 'useBinaryProtocol', protoName: 'useBinaryProtocol')
    ..aOB(18, 'queueMessages', protoName: 'queueMessages')
    ..aOB(19, 'echoMessages', protoName: 'echoMessages')
    ..aOS(20, 'recover')
    ..aOS(21, 'environment')
    ..aOB(22, 'idempotentRestPublishing', protoName: 'idempotentRestPublishing')
    ..a<$core.int>(23, 'httpOpenTimeout', $pb.PbFieldType.OU3, protoName: 'httpOpenTimeout')
    ..a<$core.int>(24, 'httpRequestTimeout', $pb.PbFieldType.OU3, protoName: 'httpRequestTimeout')
    ..a<$core.int>(25, 'httpMaxRetryCount', $pb.PbFieldType.OU3, protoName: 'httpMaxRetryCount')
    ..a<$core.int>(26, 'realtimeRequestTimeout', $pb.PbFieldType.OU3, protoName: 'realtimeRequestTimeout')
    ..pPS(27, 'fallbackHosts', protoName: 'fallbackHosts')
    ..aOB(28, 'fallbackHostsUseDefault', protoName: 'fallbackHostsUseDefault')
    ..a<$core.int>(29, 'fallbackRetryTimeout', $pb.PbFieldType.OU3, protoName: 'fallbackRetryTimeout')
    ..aOM<$3.TokenParams>(30, 'defaultTokenParams', protoName: 'defaultTokenParams', subBuilder: $3.TokenParams.create)
    ..a<$core.int>(31, 'channelRetryTimeout', $pb.PbFieldType.OU3, protoName: 'channelRetryTimeout')
    ..m<$core.String, $core.String>(32, 'transportParams', protoName: 'transportParams', entryClassName: 'ClientOptions.TransportParamsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS)
    ..hasRequiredFields = false
  ;

  ClientOptions._() : super();
  factory ClientOptions() => create();
  factory ClientOptions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientOptions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ClientOptions clone() => ClientOptions()..mergeFromMessage(this);
  ClientOptions copyWith(void Function(ClientOptions) updates) => super.copyWith((message) => updates(message as ClientOptions));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ClientOptions create() => ClientOptions._();
  ClientOptions createEmptyInstance() => create();
  static $pb.PbList<ClientOptions> createRepeated() => $pb.PbList<ClientOptions>();
  @$core.pragma('dart2js:noInline')
  static ClientOptions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientOptions>(create);
  static ClientOptions _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get authUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set authUrl($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAuthUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthUrl() => clearField(1);

  @$pb.TagNumber(2)
  HTTPMethods get authMethod => $_getN(1);
  @$pb.TagNumber(2)
  set authMethod(HTTPMethods v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAuthMethod() => $_has(1);
  @$pb.TagNumber(2)
  void clearAuthMethod() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get key => $_getSZ(2);
  @$pb.TagNumber(3)
  set key($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearKey() => clearField(3);

  @$pb.TagNumber(4)
  $3.TokenDetails get tokenDetails => $_getN(3);
  @$pb.TagNumber(4)
  set tokenDetails($3.TokenDetails v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTokenDetails() => $_has(3);
  @$pb.TagNumber(4)
  void clearTokenDetails() => clearField(4);
  @$pb.TagNumber(4)
  $3.TokenDetails ensureTokenDetails() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.Map<$core.String, $core.String> get authHeaders => $_getMap(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, $core.String> get authParams => $_getMap(5);

  @$pb.TagNumber(7)
  $core.bool get queryTime => $_getBF(6);
  @$pb.TagNumber(7)
  set queryTime($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasQueryTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearQueryTime() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get useTokenAuth => $_getBF(7);
  @$pb.TagNumber(8)
  set useTokenAuth($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUseTokenAuth() => $_has(7);
  @$pb.TagNumber(8)
  void clearUseTokenAuth() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get clientId => $_getSZ(8);
  @$pb.TagNumber(9)
  set clientId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasClientId() => $_has(8);
  @$pb.TagNumber(9)
  void clearClientId() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get logLevel => $_getIZ(9);
  @$pb.TagNumber(10)
  set logLevel($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasLogLevel() => $_has(9);
  @$pb.TagNumber(10)
  void clearLogLevel() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get tls => $_getBF(10);
  @$pb.TagNumber(11)
  set tls($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTls() => $_has(10);
  @$pb.TagNumber(11)
  void clearTls() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get restHost => $_getSZ(11);
  @$pb.TagNumber(12)
  set restHost($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasRestHost() => $_has(11);
  @$pb.TagNumber(12)
  void clearRestHost() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get realtimeHost => $_getSZ(12);
  @$pb.TagNumber(13)
  set realtimeHost($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasRealtimeHost() => $_has(12);
  @$pb.TagNumber(13)
  void clearRealtimeHost() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get port => $_getIZ(13);
  @$pb.TagNumber(14)
  set port($core.int v) { $_setUnsignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasPort() => $_has(13);
  @$pb.TagNumber(14)
  void clearPort() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get tlsPort => $_getIZ(14);
  @$pb.TagNumber(15)
  set tlsPort($core.int v) { $_setUnsignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasTlsPort() => $_has(14);
  @$pb.TagNumber(15)
  void clearTlsPort() => clearField(15);

  @$pb.TagNumber(16)
  $core.bool get autoConnect => $_getBF(15);
  @$pb.TagNumber(16)
  set autoConnect($core.bool v) { $_setBool(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasAutoConnect() => $_has(15);
  @$pb.TagNumber(16)
  void clearAutoConnect() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get useBinaryProtocol => $_getBF(16);
  @$pb.TagNumber(17)
  set useBinaryProtocol($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasUseBinaryProtocol() => $_has(16);
  @$pb.TagNumber(17)
  void clearUseBinaryProtocol() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get queueMessages => $_getBF(17);
  @$pb.TagNumber(18)
  set queueMessages($core.bool v) { $_setBool(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasQueueMessages() => $_has(17);
  @$pb.TagNumber(18)
  void clearQueueMessages() => clearField(18);

  @$pb.TagNumber(19)
  $core.bool get echoMessages => $_getBF(18);
  @$pb.TagNumber(19)
  set echoMessages($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasEchoMessages() => $_has(18);
  @$pb.TagNumber(19)
  void clearEchoMessages() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get recover => $_getSZ(19);
  @$pb.TagNumber(20)
  set recover($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasRecover() => $_has(19);
  @$pb.TagNumber(20)
  void clearRecover() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get environment => $_getSZ(20);
  @$pb.TagNumber(21)
  set environment($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasEnvironment() => $_has(20);
  @$pb.TagNumber(21)
  void clearEnvironment() => clearField(21);

  @$pb.TagNumber(22)
  $core.bool get idempotentRestPublishing => $_getBF(21);
  @$pb.TagNumber(22)
  set idempotentRestPublishing($core.bool v) { $_setBool(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasIdempotentRestPublishing() => $_has(21);
  @$pb.TagNumber(22)
  void clearIdempotentRestPublishing() => clearField(22);

  @$pb.TagNumber(23)
  $core.int get httpOpenTimeout => $_getIZ(22);
  @$pb.TagNumber(23)
  set httpOpenTimeout($core.int v) { $_setUnsignedInt32(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasHttpOpenTimeout() => $_has(22);
  @$pb.TagNumber(23)
  void clearHttpOpenTimeout() => clearField(23);

  @$pb.TagNumber(24)
  $core.int get httpRequestTimeout => $_getIZ(23);
  @$pb.TagNumber(24)
  set httpRequestTimeout($core.int v) { $_setUnsignedInt32(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasHttpRequestTimeout() => $_has(23);
  @$pb.TagNumber(24)
  void clearHttpRequestTimeout() => clearField(24);

  @$pb.TagNumber(25)
  $core.int get httpMaxRetryCount => $_getIZ(24);
  @$pb.TagNumber(25)
  set httpMaxRetryCount($core.int v) { $_setUnsignedInt32(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasHttpMaxRetryCount() => $_has(24);
  @$pb.TagNumber(25)
  void clearHttpMaxRetryCount() => clearField(25);

  @$pb.TagNumber(26)
  $core.int get realtimeRequestTimeout => $_getIZ(25);
  @$pb.TagNumber(26)
  set realtimeRequestTimeout($core.int v) { $_setUnsignedInt32(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasRealtimeRequestTimeout() => $_has(25);
  @$pb.TagNumber(26)
  void clearRealtimeRequestTimeout() => clearField(26);

  @$pb.TagNumber(27)
  $core.List<$core.String> get fallbackHosts => $_getList(26);

  @$pb.TagNumber(28)
  $core.bool get fallbackHostsUseDefault => $_getBF(27);
  @$pb.TagNumber(28)
  set fallbackHostsUseDefault($core.bool v) { $_setBool(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasFallbackHostsUseDefault() => $_has(27);
  @$pb.TagNumber(28)
  void clearFallbackHostsUseDefault() => clearField(28);

  @$pb.TagNumber(29)
  $core.int get fallbackRetryTimeout => $_getIZ(28);
  @$pb.TagNumber(29)
  set fallbackRetryTimeout($core.int v) { $_setUnsignedInt32(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasFallbackRetryTimeout() => $_has(28);
  @$pb.TagNumber(29)
  void clearFallbackRetryTimeout() => clearField(29);

  @$pb.TagNumber(30)
  $3.TokenParams get defaultTokenParams => $_getN(29);
  @$pb.TagNumber(30)
  set defaultTokenParams($3.TokenParams v) { setField(30, v); }
  @$pb.TagNumber(30)
  $core.bool hasDefaultTokenParams() => $_has(29);
  @$pb.TagNumber(30)
  void clearDefaultTokenParams() => clearField(30);
  @$pb.TagNumber(30)
  $3.TokenParams ensureDefaultTokenParams() => $_ensure(29);

  @$pb.TagNumber(31)
  $core.int get channelRetryTimeout => $_getIZ(30);
  @$pb.TagNumber(31)
  set channelRetryTimeout($core.int v) { $_setUnsignedInt32(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasChannelRetryTimeout() => $_has(30);
  @$pb.TagNumber(31)
  void clearChannelRetryTimeout() => clearField(31);

  @$pb.TagNumber(32)
  $core.Map<$core.String, $core.String> get transportParams => $_getMap(31);
}


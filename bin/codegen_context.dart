///Transmission protocol custom types. Will be used by codecs
Iterable<Map<String, dynamic>> get _types sync* {
  const platformTypes = <String>[
    // Ably flutter plugin protocol message
    'ablyMessage',
    'ablyEventMessage',

    //Other ably objects
    'clientOptions',
    'authOptions',
    'messageData',
    'messageExtras',
    'message',
    'tokenParams',
    'tokenDetails',
    'tokenRequest',
    'restChannelOptions',
    'realtimeChannelOptions',
    'paginatedResult',
    'restHistoryParams',
    'realtimeHistoryParams',
    'restPresenceParams',
    'presenceMessage',
    'realtimePresenceParams',

    // Push Notifications
    'deviceDetails',
    'localDevice',
    'pushChannelSubscription',
    'unNotificationSettings',
    'remoteMessage',

    'errorInfo',
    'logLevel',

    // Events
    'connectionStateChange',
    'channelStateChange',

    // Encryption
    'cipherParams',
  ];

  // Custom type values must be over 127. At the time of writing
  // the standard message codec encodes them as an unsigned byte
  // which means the maximum type value is 255. If we get to the
  // point of having more than that number of custom types (i.e.
  // more than 128 [255 - 127]) then we can either roll our own
  // codec from scratch or, perhaps easier, reserve custom type
  // value 255 to indicate that it will be followed by a subtype
  // value - perhaps of a wider type.
  //
  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
  var index = 128;
  for (final platformType in platformTypes) {
    yield {'name': platformType, 'value': index++};
  }
}

///Platform method names
const List<Map<String, dynamic>> _platformMethods = [
  {'name': 'getPlatformVersion', 'value': 'getPlatformVersion'},
  {'name': 'getVersion', 'value': 'getVersion'},
  {'name': 'resetAblyClients', 'value': 'resetAblyClients'},

  // Auth
  {'name': 'authCallback', 'value': 'authCallback'},
  {'name': 'realtimeAuthCallback', 'value': 'realtimeAuthCallback'},

  // Rest
  {'name': 'createRest', 'value': 'createRest'},
  {'name': 'setRestChannelOptions', 'value': 'setRestChannelOptions'},
  {'name': 'publish', 'value': 'publish'},
  {'name': 'restHistory', 'value': 'restHistory'},
  {'name': 'restPresenceGet', 'value': 'restPresenceGet'},
  {'name': 'restPresenceHistory', 'value': 'restPresenceHistory'},
  {'name': 'releaseRestChannel', 'value': 'releaseRestChannel'},
  {'name': 'restAuthAuthorize', 'value': 'restAuthAuthorize'},
  {'name': 'restAuthCreateTokenRequest', 'value': 'restAuthCreateTokenRequest'},
  {'name': 'restAuthRequestToken', 'value': 'restAuthRequestToken'},
  {'name': 'restAuthGetClientId', 'value': 'restAuthGetClientId'},

  // Realtime
  {'name': 'createRealtime', 'value': 'createRealtime'},
  {'name': 'connectRealtime', 'value': 'connectRealtime'},
  {'name': 'closeRealtime', 'value': 'closeRealtime'},
  {'name': 'attachRealtimeChannel', 'value': 'attachRealtimeChannel'},
  {'name': 'detachRealtimeChannel', 'value': 'detachRealtimeChannel'},
  {'name': 'setRealtimeChannelOptions', 'value': 'setRealtimeChannelOptions'},
  {'name': 'realtimePresenceGet', 'value': 'realtimePresenceGet'},
  {'name': 'realtimePresenceHistory', 'value': 'realtimePresenceHistory'},
  {'name': 'realtimePresenceEnter', 'value': 'realtimePresenceEnter'},
  {'name': 'realtimePresenceUpdate', 'value': 'realtimePresenceUpdate'},
  {'name': 'realtimePresenceLeave', 'value': 'realtimePresenceLeave'},
  {'name': 'onRealtimePresenceMessage', 'value': 'onRealtimePresenceMessage'},
  {
    'name': 'publishRealtimeChannelMessage',
    'value': 'publishRealtimeChannelMessage'
  },
  {'name': 'releaseRealtimeChannel', 'value': 'releaseRealtimeChannel'},
  {'name': 'realtimeHistory', 'value': 'realtimeHistory'},
  {'name': 'realtimeTime', 'value': 'realtimeTime'},
  {'name': 'restTime', 'value': 'restTime'},
  {'name': 'realtimeAuthAuthorize', 'value': 'realtimeAuthAuthorize'},
  {
    'name': 'realtimeAuthCreateTokenRequest',
    'value': 'realtimeAuthCreateTokenRequest'
  },
  {'name': 'realtimeAuthRequestToken', 'value': 'realtimeAuthRequestToken'},
  {'name': 'realtimeAuthGetClientId', 'value': 'realtimeAuthGetClientId'},

  // Push Notifications
  {'name': 'pushActivate', 'value': 'pushActivate'},
  {'name': 'pushDeactivate', 'value': 'pushDeactivate'},
  {'name': 'pushReset', 'value': 'pushReset'},
  {'name': 'pushSubscribeDevice', 'value': 'pushSubscribeDevice'},
  {'name': 'pushUnsubscribeDevice', 'value': 'pushUnsubscribeDevice'},
  {'name': 'pushSubscribeClient', 'value': 'pushSubscribeClient'},
  {'name': 'pushUnsubscribeClient', 'value': 'pushUnsubscribeClient'},
  {'name': 'pushListSubscriptions', 'value': 'pushListSubscriptions'},
  {'name': 'pushDevice', 'value': 'pushDevice'},
  // Used only on iOS
  {'name': 'pushRequestPermission', 'value': 'pushRequestPermission'},
  // Used only on iOS
  {
    'name': 'pushGetNotificationSettings',
    'value': 'pushGetNotificationSettings'
  },
  // Used only on iOS
  {'name': 'pushOpenSettingsFor', 'value': 'pushOpenSettingsFor'},
  // Push Activation Events
  {'name': 'pushOnActivate', 'value': 'pushOnActivate'},
  {'name': 'pushOnDeactivate', 'value': 'pushOnDeactivate'},
  {'name': 'pushOnUpdateFailed', 'value': 'pushOnUpdateFailed'},
  // Push Notification Events
  {
    'name': 'pushNotificationTapLaunchedAppFromTerminated',
    'value': 'pushNotificationTapLaunchedAppFromTerminated'
  },
  {
    'name': 'pushOnShowNotificationInForeground',
    'value': 'pushOnShowNotificationInForeground'
  },
  {'name': 'pushOnMessage', 'value': 'pushOnMessage'},
  {'name': 'pushOnBackgroundMessage', 'value': 'pushOnBackgroundMessage'},
  {'name': 'pushOnNotificationTap', 'value': 'pushOnNotificationTap'},
  // Used only on Android
  {
    'name': 'pushBackgroundFlutterApplicationReadyOnAndroid',
    'value': 'pushBackgroundFlutterApplicationReadyOnAndroid'
  },

  // Realtime events
  {
    'name': 'onRealtimeConnectionStateChanged',
    'value': 'onRealtimeConnectionStateChanged'
  },
  {
    'name': 'onRealtimeChannelStateChanged',
    'value': 'onRealtimeChannelStateChanged'
  },
  {'name': 'onRealtimeChannelMessage', 'value': 'onRealtimeChannelMessage'},

  // Paginated results
  {'name': 'nextPage', 'value': 'nextPage'},
  {'name': 'firstPage', 'value': 'firstPage'},

  // Encryption
  {'name': 'cryptoGetParams', 'value': 'cryptoGetParams'},
  {'name': 'cryptoGenerateRandomKey', 'value': 'cryptoGenerateRandomKey'},
];

const List<Map<String, dynamic>> _objects = [
  // TransportKeys exist to synchronize the string constants used in data
  // structures sent between platforms. For example, you can see
  // usages of [TxTransportKeys.channelName]
  {
    'name': 'TransportKeys',
    'properties': <String>[
      'channelName',
      'params',
      'data',
      'clientId',
      'options',
      'messages',
    ]
  },
  {
    'name': 'AblyMessage',
    'properties': <String>['registrationHandle', 'type', 'message']
  },
  {
    'name': 'AblyEventMessage',
    'properties': <String>['eventName', 'type', 'message']
  },
  {
    'name': 'ErrorInfo',
    'properties': <String>[
      'code',
      'message',
      'statusCode',
      'href',
      'requestId',
      'cause'
    ]
  },
  {
    'name': 'MessageData',
    'properties': <String>['data', 'type']
  },
  {
    'name': 'DeltaExtras',
    'properties': <String>['format', 'from']
  },
  {
    'name': 'MessageExtras',
    'properties': <String>['extras', 'delta']
  },
  {
    'name': 'ClientOptions',
    'properties': <String>[
      // Auth options
      'authUrl',
      'authMethod',
      'key',
      'tokenDetails',
      'authHeaders',
      'authParams',
      'queryTime',
      'useTokenAuth',
      'hasAuthCallback',
      // ClientOptions
      'clientId',
      'logLevel',
      'tls',
      'restHost',
      'realtimeHost',
      'port',
      'tlsPort',
      'autoConnect',
      'useBinaryProtocol',
      'queueMessages',
      'echoMessages',
      'recover',
      'environment',
      'idempotentRestPublishing',
      'httpOpenTimeout',
      'httpRequestTimeout',
      'httpMaxRetryCount',
      'realtimeRequestTimeout',
      'fallbackHosts',
      'fallbackHostsUseDefault',
      'fallbackRetryTimeout',
      'defaultTokenParams',
      'channelRetryTimeout',
      'transportParams',
      'dartVersion',
    ]
  },
  {
    'name': 'RestChannelOptions',
    'properties': <String>['cipherParams']
  },
  {
    'name': 'RealtimeChannelOptions',
    'properties': <String>['params', 'modes', 'cipherParams']
  },
  {
    'name': 'CipherParams',
    'properties': <String>['androidHandle', 'iosAlgorithm', 'iosKey'],
  },
  {
    'name': 'TokenDetails',
    'properties': <String>[
      'token',
      'expires',
      'issued',
      'capability',
      'clientId'
    ]
  },
  {
    'name': 'AuthOptions',
    'properties': <String>[
      'authCallback',
      'authUrl',
      'authMethod',
      'key',
      'token',
      'tokenDetails',
      'authHeaders',
      'authParams',
      'queryTime',
      'useTokenAuth'
    ]
  },
  {
    'name': 'TokenParams',
    'properties': <String>[
      'capability',
      'clientId',
      'nonce',
      'timestamp',
      'ttl'
    ]
  },
  {
    'name': 'TokenRequest',
    'properties': <String>[
      'capability',
      'clientId',
      'keyName',
      'mac',
      'nonce',
      'timestamp',
      'ttl'
    ]
  },
  {
    'name': 'EnumConstants',
    'properties': <String>[
      // connection & channel - states & events
      'initialized',
      'connecting',
      'connected',
      'disconnected',
      'attaching',
      'attached',
      'detaching',
      'detached',
      'suspended',
      'closing',
      'closed',
      'failed',
      // Presence actions
      'absent',
      'leave',
      'enter',
      'present',
      'update',
      // channel modes
      'presence',
      'publish',
      'subscribe',
      'presenceSubscribe'
    ]
  },
  {
    'name': 'FormFactorEnum',
    'properties': <String>[
      'phone',
      'tablet',
      'desktop',
      'tv',
      'watch',
      'car',
      'embedded',
      'other'
    ]
  },
  {
    'name': 'LogLevelEnum',
    'properties': ['none', 'verbose', 'debug', 'info', 'warn', 'error'],
  },
  {
    'name': 'DevicePlatformEnum',
    'properties': <String>['ios', 'android', 'browser']
  },
  {
    'name': 'DevicePushStateEnum',
    'properties': <String>['active', 'failing', 'failed']
  },
  {
    'name': 'ConnectionStateChange',
    'properties': <String>['current', 'previous', 'event', 'retryIn', 'reason']
  },
  {
    'name': 'ChannelStateChange',
    'properties': <String>['current', 'previous', 'event', 'resumed', 'reason']
  },
  {
    'name': 'Message',
    'properties': <String>[
      'id',
      'timestamp',
      'clientId',
      'connectionId',
      'encoding',
      'data',
      'name',
      'extras'
    ]
  },
  {
    'name': 'PresenceMessage',
    'properties': <String>[
      'id',
      'action',
      'clientId',
      'connectionId',
      'data',
      'encoding',
      'extras',
      'timestamp',
    ]
  },
  {
    'name': 'PaginatedResult',
    'properties': <String>['items', 'type', 'hasNext']
  },
  {
    'name': 'RestHistoryParams',
    'properties': <String>[
      'start',
      'end',
      'direction',
      'limit',
    ]
  },
  {
    'name': 'RealtimeHistoryParams',
    'properties': <String>[
      'start',
      'end',
      'direction',
      'limit',
      'untilAttach',
    ]
  },
  {
    'name': 'RestPresenceParams',
    'properties': <String>[
      'limit',
      'clientId',
      'connectionId',
    ]
  },
  {
    'name': 'RealtimePresenceParams',
    'properties': <String>[
      'waitForSync',
      'clientId',
      'connectionId',
    ]
  },
  {
    'name': 'DeviceDetails',
    'properties': <String>[
      'id',
      'clientId',
      'platform',
      'formFactor',
      'metadata',
      'devicePushDetails'
    ]
  },
  {
    'name': 'DevicePushDetails',
    'properties': <String>['recipient', 'state', 'errorReason']
  },
  {
    'name': 'LocalDevice',
    'properties': <String>['deviceSecret', 'deviceIdentityToken']
  },
  {
    'name': 'PushChannelSubscription',
    'properties': <String>['channel', 'deviceId', 'clientId']
  },
  {
    'name': 'PushRequestPermission',
    'properties': <String>[
      'badge',
      'sound',
      'alert',
      'carPlay',
      'criticalAlert',
      'providesAppNotificationSettings',
      'provisional',
      'announcement',
    ]
  },
  {
    'name': 'UNNotificationSettings',
    'properties': <String>[
      'authorizationStatus',
      'soundSetting',
      'badgeSetting',
      'alertSetting',
      'notificationCenterSetting',
      'lockScreenSetting',
      'carPlaySetting',
      'alertStyle',
      'showPreviewsSetting',
      'criticalAlertSetting',
      'providesAppNotificationSettings',
      'announcementSetting',
      'scheduledDeliverySetting',
      'timeSensitiveSetting',
    ]
  },
  {
    'name': 'UNNotificationSettingEnum',
    'properties': ['notSupported', 'disabled', 'enabled']
  },
  {
    'name': 'UNAlertStyleEnum',
    'properties': ['none', 'banner', 'alert']
  },
  {
    'name': 'UNAuthorizationStatusEnum',
    'properties': [
      'notDetermined',
      'denied',
      'authorized',
      'provisional',
      'ephemeral',
    ]
  },
  {
    'name': 'UNShowPreviewsSettingEnum',
    'properties': ['always', 'whenAuthenticated', 'never']
  },
  {
    'name': 'RemoteMessage',
    'properties': [
      'data',
      'notification',
    ]
  },
  {
    'name': 'Notification',
    'properties': ['title', 'body']
  },
  {
    'name': 'CryptoGetParams',
    'properties': ['algorithm', 'key']
  },
  {
    'name': 'CryptoGenerateRandomKey',
    'properties': ['keyLength']
  }
];

// exporting all the constants as a single map
// which can be directly fed to template as context
Map<String, dynamic> context = {
  'types': _types,
  'methods': _platformMethods,
  'objects': _objects
};

///Transmission protocol custom types. Will be used by codecs
List<Map<String, dynamic>> _types = [
  // Custom type values must be over 127. At the time of writing the standard message
  // codec encodes them as an unsigned byte which means the maximum type value is 255.
  // If we get to the point of having more than that number of custom types (i.e. more
  // than 128 [255 - 127]) then we can either roll our own codec from scratch or,
  // perhaps easier, reserve custom type value 255 to indicate that it will be followed
  // by a subtype value - perhaps of a wider type.
  //
  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html

  //Ably flutter plugin protocol message
  {"name": "ablyMessage", "value": 128},

  //Other ably objects
  {"name": "clientOptions", "value": 129},
  {"name": "tokenDetails", "value": 130},
  {"name": "errorInfo", "value": 144},

  // Events
  {"name": "connectionEvent", "value": 201},
  {"name": "connectionState", "value": 202},
  {"name": "connectionStateChange", "value": 203},
  {"name": "channelEvent", "value": 204},
  {"name": "channelState", "value": 205},
  {"name": "channelStateChange", "value": 206}
];

///Platform method names
List<Map<String, dynamic>> _platformMethods = [
  {"name": "getPlatformVersion", "value": "getPlatformVersion"},
  {"name": "getVersion", "value": "getVersion"},
  {"name": "registerAbly", "value": "registerAbly"},

  // Rest
  {"name": "createRestWithOptions", "value": "createRestWithOptions"},
  {"name": "publish", "value": "publish"},

  // Realtime
  {"name": "createRealtimeWithOptions", "value": "createRealtimeWithOptions"},
  {"name": "connectRealtime", "value": "connectRealtime"},
  {"name": "closeRealtime", "value": "closeRealtime"},

  //Realtime events
  {"name": "onRealtimeConnectionStateChanged", "value": "onRealtimeConnectionStateChanged"},
  {"name": "onRealtimeChannelStateChanged", "value": "onRealtimeChannelStateChanged"}
];


//exporting all the constants as a single map
// which can be directly fed to template as context
Map<String, dynamic> context = {
  "types": _types,
  "methods": _platformMethods
};

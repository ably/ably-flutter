import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// A collection of Channel objects accessible
/// through [Rest.channels] or [Realtime.channels]
abstract class Channels<ChannelType> extends Iterable<ChannelType> {
  /// stores channel name vs instance of [ChannelType]
  final _channels = <String, ChannelType>{};

  /// creates a channel with provided name and options
  ///
  /// This is a private method to be overridden by implementation classes
  @protected
  ChannelType createChannel(String name);

  /// creates a channel with [name].
  ///
  /// Doesn't create a channel instance on platform side yet.
  ChannelType get(String name) {
    if (_channels[name] == null) {
      _channels[name] = createChannel(name);
    }
    return _channels[name]!;
  }

  /// returns true if a channel exists [name]
  bool exists(String name) => _channels[name] != null;

  /// Same as [get].
  ChannelType operator [](String name) => get(name);

  @override
  Iterator<ChannelType> get iterator =>
      _ChannelIterator<ChannelType>(_channels.values.toList());

  /// Releases the channel resource so it can be garbage collected
  void release(String name) {
    _channels.remove(name);
  }
}

/// Iterator class for [Channels.iterator]
class _ChannelIterator<T> implements Iterator<T> {
  _ChannelIterator(this._channels);

  final List<T> _channels;

  int _currentIndex = 0;

  T? _currentChannel;

  @override
  T get current {
    if (_currentChannel == null) {
      throw StateError('Not iterating');
    }
    return _currentChannel!;
  }

  @override
  bool moveNext() {
    if (_currentIndex == _channels.length) {
      return false;
    }
    _currentChannel = _channels[_currentIndex++];
    return true;
  }
}

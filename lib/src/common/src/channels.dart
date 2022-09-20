import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A collection of Channel objects accessible
/// through [Rest.channels] or [Realtime.channels]
/// END LEGACY DOCSTRING
abstract class Channels<ChannelType> extends Iterable<ChannelType> {
  /// BEGIN LEGACY DOCSTRING
  /// stores channel name vs instance of [ChannelType]
  /// END LEGACY DOCSTRING
  final _channels = <String, ChannelType>{};

  /// BEGIN LEGACY DOCSTRING
  /// creates a channel with provided name and options
  ///
  /// This is a private method to be overridden by implementation classes
  /// END LEGACY DOCSTRING
  @protected
  ChannelType createChannel(String name);

  /// BEGIN LEGACY DOCSTRING
  /// creates a channel with [name].
  ///
  /// Doesn't create a channel instance on platform side yet.
  /// END LEGACY DOCSTRING
  ChannelType get(String name) {
    if (_channels[name] == null) {
      _channels[name] = createChannel(name);
    }
    return _channels[name]!;
  }

  /// BEGIN LEGACY DOCSTRING
  /// returns true if a channel exists [name]
  /// END LEGACY DOCSTRING
  bool exists(String name) => _channels[name] != null;

  /// BEGIN LEGACY DOCSTRING
  /// Same as [get].
  /// END LEGACY DOCSTRING
  ChannelType operator [](String name) => get(name);

  @override
  Iterator<ChannelType> get iterator =>
      _ChannelIterator<ChannelType>(_channels.values.toList());

  /// BEGIN LEGACY DOCSTRING
  /// Releases the channel resource so it can be garbage collected
  /// END LEGACY DOCSTRING
  void release(String name) {
    _channels.remove(name);
  }
}

/// BEGIN LEGACY DOCSTRING
/// Iterator class for [Channels.iterator]
/// END LEGACY DOCSTRING
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

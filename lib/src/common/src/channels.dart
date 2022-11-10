import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A collection of Channel objects accessible
/// through [Rest.channels] or [Realtime.channels]
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Creates and destroys [RestChannel] and [RealtimeChannel] objects.
/// END EDITED CANONICAL DOCSTRING
abstract class Channels<ChannelType> extends Iterable<ChannelType> {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// stores channel name vs instance of [ChannelType]
  /// END LEGACY DOCSTRING
  final _channels = <String, ChannelType>{};

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Creates a new [RestChannel] or [RealtimeChannel] object, or returns the
  /// existing channel object, using the channel [name] parameter.
  /// END EDITED CANONICAL DOCSTRING
  ChannelType get(String name) {
    if (_channels[name] == null) {
      _channels[name] = createChannel(name);
    }
    return _channels[name]!;
  }

  /// BEGIN LEGACY DOCSTRING
  /// returns true if a channel exists [name]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Checks whether a channel with a [name] has been previously retrieved using
  /// the `get()` method. Returns `true` if the channel exists, otherwise
  /// `false`.
  /// END EDITED CANONICAL DOCSTRING
  bool exists(String name) => _channels[name] != null;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Same as [get].
  /// END LEGACY DOCSTRING
  ChannelType operator [](String name) => get(name);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Iterates through the existing channels.
  /// END EDITED CANONICAL DOCSTRING
  @override
  Iterator<ChannelType> get iterator =>
      _ChannelIterator<ChannelType>(_channels.values.toList());

  /// BEGIN LEGACY DOCSTRING
  /// Releases the channel resource so it can be garbage collected
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Releases a [RestChannel] or [RealtimeChannel] object with a specified
  /// [name], deleting it. It also removes any listeners associated with the
  /// channel. To release a channel, the [ChannelState] must be `INITIALIZED`,
  /// `DETACHED`, or `FAILED`f.
  /// END EDITED CANONICAL DOCSTRING
  void release(String name) {
    _channels.remove(name);
  }
}

/// BEGIN LEGACY DOCSTRING
/// @nodoc
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

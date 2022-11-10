import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Creates and destroys [RestChannel] and [RealtimeChannel] objects.
/// END EDITED CANONICAL DOCSTRING
abstract class Channels<ChannelType> extends Iterable<ChannelType> {
  /// @nodoc
  /// stores channel name vs instance of [ChannelType]
  final _channels = <String, ChannelType>{};

  /// @nodoc
  /// creates a channel with provided name and options
  ///
  /// This is a private method to be overridden by implementation classes
  @protected
  ChannelType createChannel(String name);

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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Checks whether a channel with a [name] has been previously retrieved using
  /// the `get()` method. Returns `true` if the channel exists, otherwise
  /// `false`.
  /// END EDITED CANONICAL DOCSTRING
  bool exists(String name) => _channels[name] != null;

  /// @nodoc
  /// Same as [get].
  ChannelType operator [](String name) => get(name);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Iterates through the existing channels.
  /// END EDITED CANONICAL DOCSTRING
  @override
  Iterator<ChannelType> get iterator =>
      _ChannelIterator<ChannelType>(_channels.values.toList());

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

/// @nodoc
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

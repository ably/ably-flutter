import 'dart:async';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

typedef Injector = int? Function(int id);

Stream<int> emitter(int id, Injector injector) async* {
  var injectable = injector(id);
  while (injectable != null) {
    yield injectable;
    injectable = injector(id);
  }
}

class MockEmitter {
  MockEmitter(this.streamsCount, this.injectables) {
    for (var i = 0; i < streamsCount; i++) {
      streams.add(emitter(i, injector));
      indexes[i] = 0;
    }
  }

  int streamsCount;
  Map<int, int> indexes = {};
  List<int> injectables;
  final streams = <Stream<int>>[];

  int emitCount = 0;

  int? injector(int id) {
    // ignore: avoid_returning_null
    if (indexes[id]! >= injectables.length) return null;
    final ret = injectables[indexes[id]!];
    indexes[id] = indexes[id]! + 1;
    return ret;
  }
}

Function eq = const ListEquality().equals;

void main() {
  test('RTE6a: nested cancellation of a listener', () async {
    //lists to store data received by listeners
    final resultsDefault = <int>[];
    final resultsNestedPre = <int>[];
    final resultsNestedPost = <int>[];

    final emitter = MockEmitter(3, [1, 2, 3, 4, 5]);
    final streams = emitter.streams;

    StreamSubscription<dynamic> subscriptionPre;
    late StreamSubscription<dynamic> subscriptionPost;

    subscriptionPre = streams[1].listen(resultsNestedPre.add);

    //subscription2
    streams[0].listen((eventValue) {
      resultsDefault.add(eventValue);
      //cancelling subscriptionPre and subscriptionPost when value is 2
      if (eventValue == 2) {
        subscriptionPre.cancel();
        subscriptionPost.cancel();
      }
    });

    subscriptionPost = streams[2].listen(resultsNestedPost.add);

    //Waiting for stream to end
    await Future.delayed(Duration.zero);

    //Checking if data received by stream is same as expected
    expect(
        const ListEquality().equals(resultsDefault, emitter.injectables), true);
    expect(const ListEquality().equals(resultsNestedPre, [1, 2]), true);
    expect(const ListEquality().equals(resultsNestedPost, [1]), true);
  });
}

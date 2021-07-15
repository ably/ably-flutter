import 'package:flutter/widgets.dart';

/// TODO Use stream builder to choose when to disable.
/// If stream shows state is not ready (e.g. not connected, or null client), disable button.
class StateAwareButton<T> extends StatelessWidget {
  Stream<T> stream;

  StateAwareButton(this.stream, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: stream, builder: (context, snapshot) {
      if () {
        // TODO return a loading button
      }

      if (snapshot.hasData) {
        // If
      }
    });
  }
}

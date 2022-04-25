import 'package:flutter/material.dart';

/// A Text which has a bold label, followed by a colon:
/// For example, in Markdown it will look like `**label:** text`
class TextRow extends StatelessWidget {
  final String label;
  final String? text;

  const TextRow(this.label, this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => RichText(
          text: TextSpan(children: [
        TextSpan(text: '$label: ', style: const TextStyle(color: Colors.blue)),
        TextSpan(text: text, style: const TextStyle(color: Colors.black))
      ]));
}

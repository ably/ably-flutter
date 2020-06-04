String $(c) {
  return '''
class CodecTypes{
  ${c['types'].map((_) => "static const int ${_['name']} = ${_['value']};").join('\n\t')}
}

class PlatformMethod {
  ${c['methods'].map((_) => "static const String ${_['name']} = '${_['value']}';").join('\n\t')}
}

${c['objects'].map((_) {
    return '''
class Tx${_['name']}{
  ${_['properties'].map((_p) => 'static const String ${_p} = "${_p}";').join('\n\t')}
}
''';}).join('\n')}
''';
}

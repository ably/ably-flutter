## Code generation to keep platform constants in sync

#### Generating files

```bash
cd bin
dart codegen.dart
```

#### Template format

This generation is based on a 2 simple Regular expressions which work as below:

input template contents
```text
Hola {{variable}}!
```

input context
```dart
Map context = {
  "variable": "World"
};
```

output file content
```text
Hola World
```

input template contents
```text
{{#each list}}
    String {{name}} = "{{value}}";
{{/each}}
```

input context
```dart
Map context = {
  "list": [
    {"var1": "title", "var2": "Lorem Ipsum"},
    {"var1": "description", "var2": "Lorem ipsum dolor sit amet, consectetur adipiscing elit"},
  ]
};
```

output file content
```text

    String title = "Lorem Ipsum";

    String description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit";

```
_mind the linebreaks_


#### Template and Context files

source template files are available in `bin/templates`
 and source context data in `bin/codegencontext.dart`.

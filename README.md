# SharedPreferences_riverpod

Make it easier to access SharePreferences using Riverpod's Provider.

- https://pub.dev/packages/shared_preferences
- https://pub.dev/packages/riverpod

## Usage

### Primitive type or List\<String\>

- Create `Provider` with `createPrefProvider` and generics parameter.

```dart
final booPrefProvider = createPrefProvider<bool>(
  prefs: (_) => prefs,
  prefKey: "boolValue",
  defaultValue: false,
);
```

- Refer values with `ref.watch(provider)`.
- Update value with `await ref.read(provider).update(newValue);`.

```dart
Consumer(builder: (context, ref, _) {
  return CheckboxListTile(
    title: Text('checkbox'),
    value: ref.watch(booPrefProvider),
    onChanged: (v) async {
        if (v != null) await ref.read(booPrefProvider.notifier).update(v);
    },
  );
}
```
### Other types

- Create `Provider` with `createPrefProvider` and map functions.

```dart
enum EnumValues {
  foo,
  bar,
}

final enumPrefProvider = createMapPrefProvider<EnumValues>(
  prefs: (_) => prefs,
  prefKey: "enumValue",
  mapFrom: (v) => EnumValues.values
      .firstWhere((e) => e.toString() == v, orElse: () => EnumValues.foo),
  mapTo: (v) => v.toString(),
);

```

- Refer values with `ref.watch(provider)`.
- Update value with `await ref.read(provider).update(newValue);`.

```dart
Consumer(builder: (context, ref, _) {
  return RadioListTile(
    title: Text('value1'),
    value: EnumValues.foo,
    groupValue: ref.watch(enumPrefProvider),
    onChanged: (EnumValues? v) async {
      if (v != null) await ref.read(enumPrefProvider.notifier).update(v);
    },
  );
}
```

### Example

```dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_riverpod/shared_preferences_riverpod.dart';

late SharedPreferences prefs;

final booPrefProvider = createPrefProvider<bool>(
  prefs: (_) => prefs,
  prefKey: "boolValue",
  defaultValue: false,
);

enum EnumValues {
  foo,
  bar,
}

final enumPrefProvider = createMapPrefProvider<EnumValues>(
  prefs: (_) => prefs,
  prefKey: "enumValue",
  mapFrom: (v) => EnumValues.values
      .firstWhere((e) => e.toString() == v, orElse: () => EnumValues.foo),
  mapTo: (v) => v.toString(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample',
      home: Scaffold(
        appBar: AppBar(),
        body: Consumer(builder: (context, ref, _) {
          return ListView(children: [
            CheckboxListTile(
              title: Text('BoolPrefNotifier ${ref.watch(booPrefProvider)}'),
              value: ref.watch(booPrefProvider),
              onChanged: (v) async {
                if (v != null)
                  await ref.read(booPrefProvider.notifier).update(v);
              },
            ),
            RadioListTile(
              title: Text('${EnumValues.foo.toString()}'),
              value: EnumValues.foo,
              groupValue: ref.watch(enumPrefProvider),
              onChanged: (EnumValues? v) async {
                if (v != null)
                  await ref.read(enumPrefProvider.notifier).update(v);
              },
            ),
            RadioListTile(
              title: Text('${EnumValues.bar.toString()}'),
              value: EnumValues.bar,
              groupValue: ref.watch(enumPrefProvider),
              onChanged: (EnumValues? v) async {
                if (v != null)
                  await ref.read(enumPrefProvider.notifier).update(v);
              },
            ),
          ]);
        }),
      ),
    );
  }
}

```

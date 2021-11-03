# SharedPreferences riverpod

Make it easier to access SharePreferences using Riverpod's Provider.

https://pub.dev/packages/shared_preferences
https://pub.dev/packages/riverpod

## Usage

```dart

final booPrefProvider = createPrefNotifierProvider<bool>(
  prefs: (_) => prefs,
  prefKey: "boolValue",
  defaultValue: false,
);

enum EnumValues {
  foo,
  bar,
}

final enumPrefProvider = createEnumPrefNotifierProvider<EnumValues>(
  prefs: (_) => prefs,
  prefKey: "enumValue",
  mapFrom: (v) => EnumValues.values
      .firstWhere((e) => e.toString() == v, orElse: () => EnumValues.foo),
  mapTo: (v) => v.toString(),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample',
      home: Scaffold(
        appBar: AppBar(),
        body: Consumer(builder: (context, watch, _) {
          return ListView(children: [
            CheckboxListTile(
              title: Text('BoolPrefNotifier ${watch(booPrefProvider)}'),
              value: watch(booPrefProvider),
              onChanged: (v) {
                if (v != null) watch(booPrefProvider.notifier).update(v);
              },
            ),
            RadioListTile(
              title: Text('Enum ${EnumValues.foo.toString()}'),
              value: EnumValues.foo,
              groupValue: watch(enumPrefProvider),
              onChanged: (EnumValues? v) {
                if (v != null) watch(enumPrefProvider.notifier).update(v);
              },
            ),
            RadioListTile(
              title: Text('Enum ${EnumValues.foo.toString()}'),
              value: EnumValues.bar,
              groupValue: watch(enumPrefProvider),
              onChanged: (EnumValues? v) {
                if (v != null) watch(enumPrefProvider.notifier).update(v);
              },
            ),
          ]);
        }),
      ),
    );
  }
}

```

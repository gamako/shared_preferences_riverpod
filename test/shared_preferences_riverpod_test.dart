import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_riverpod/shared_preferences_riverpod.dart';

class MyApp<T> extends StatelessWidget {
  MyApp(SharedPreferences prefs, String keyName, T defaultValue, this.newValue)
      : provider = createPrefProvider<T>(
          prefs: (_) => prefs,
          prefKey: keyName,
          defaultValue: defaultValue,
        );
  final provider;
  final T newValue;

  @override
  Widget build(context) {
    return ProviderScope(child: Consumer(builder: (context, watch, _) {
      final T value = watch(provider);
      return ProviderScope(
        child: MaterialApp(
          home: ElevatedButton(
            onPressed: () async {
              await watch(provider.notifier).update(newValue);
            },
            child: Text('$value'),
          ),
        ),
      );
    }));
  }
}

enum EnumType {
  type1,
  type2,
  type3,
}

class MyMapApp extends StatelessWidget {
  MyMapApp(SharedPreferences prefs, String keyName)
      : provider = createMapPrefProvider<EnumType>(
          prefs: (_) => prefs,
          prefKey: keyName,
          mapFrom: (v) => EnumType.values.firstWhere((e) => e.toString() == v,
              orElse: () => EnumType.type1),
          mapTo: (v) => v.toString(),
        );
  final provider;

  @override
  Widget build(context) {
    return ProviderScope(child: Consumer(builder: (context, watch, _) {
      final value = watch(provider);
      return ProviderScope(
        child: MaterialApp(
          home: ElevatedButton(
            onPressed: () async {
              await watch(provider.notifier).update(EnumType.type2);
            },
            child: Text('$value'),
          ),
        ),
      );
    }));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shared_preferences_riverpod', () {
    const String testString = 'hello world';
    const bool testBool = true;
    const int testInt = 42;
    const double testDouble = 3.14159;
    const List<String> testList = <String>['foo', 'bar'];
    const String testEnum = 'EnumType.type3';

    const String testString2 = 'goodbye world';
    const bool testBool2 = false;
    const int testInt2 = 1337;
    const double testDouble2 = 2.71828;
    const List<String> testList2 = <String>['baz', 'quox'];
    const String testEnum2 = 'EnumType.type2';

    const Map<String, Object> testValues = <String, Object>{
      'flutter.String': testString,
      'flutter.bool': testBool,
      'flutter.int': testInt,
      'flutter.double': testDouble,
      'flutter.List': testList,
      'flutter.EnumType': testEnum,
    };

    late FakeSharedPreferencesStore store;
    late SharedPreferences preferences;

    final setUpFunc = () async {
      store = FakeSharedPreferencesStore(testValues);
      SharedPreferencesStorePlatform.instance = store;
      preferences = await SharedPreferences.getInstance();
      preferences.reload();
      store.log.clear();
    };

    final tearDown = () async {
      await preferences.clear();
      await store.clear();
    };

    testWidgets('reading and writing', (t) async {
      await setUpFunc();
      try {
        await t.pumpWidget(MyApp(preferences, 'String', '', testString2));
        expect(find.text('$testString'), findsOneWidget);
        await t.tap(find.byType(ElevatedButton));
        await t.pump();
        expect(find.text(testString2), findsOneWidget);

        await t.pumpWidget(MyApp<bool>(preferences, 'bool', false, testBool2));
        expect(find.text('$testBool'), findsOneWidget);
        await t.tap(find.byType(ElevatedButton));
        await t.pump();
        expect(find.text('$testBool2'), findsOneWidget);

        await t.pumpWidget(MyApp<int>(preferences, 'int', 0, testInt2));
        expect(find.text('$testInt'), findsOneWidget);
        await t.tap(find.byType(ElevatedButton));
        await t.pump();
        expect(find.text('$testInt2'), findsOneWidget);

        await t
            .pumpWidget(MyApp<double>(preferences, 'double', 0, testDouble2));
        expect(find.text('$testDouble'), findsOneWidget);
        await t.tap(find.byType(ElevatedButton));
        await t.pump();
        expect(find.text('$testDouble2'), findsOneWidget);

        await t.pumpWidget(
            MyApp<List<String>>(preferences, 'List', [], testList2));
        expect(find.text("$testList"), findsOneWidget);
        await t.tap(find.byType(ElevatedButton));
        await t.pump();
        expect(find.text('$testList2'), findsOneWidget);

        await t.pumpWidget(MyMapApp(preferences, "EnumType"));
        expect(find.text('$testEnum'), findsOneWidget);
        await t.tap(find.byType(ElevatedButton));
        await t.pump();
        expect(find.text('$testEnum2'), findsOneWidget);

        expect(store.log, <Matcher>[
          isMethodCall('setValue', arguments: <dynamic>[
            'String',
            'flutter.String',
            testString2,
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'Bool',
            'flutter.bool',
            testBool2,
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'Int',
            'flutter.int',
            testInt2,
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'Double',
            'flutter.double',
            testDouble2,
          ]),
          isMethodCall('setValue',
              arguments: <dynamic>['StringList', 'flutter.List', testList2]),
          isMethodCall('setValue', arguments: <dynamic>[
            'String',
            'flutter.EnumType',
            testEnum2,
          ]),
        ]);
      } finally {
        await tearDown();
      }
    });

    testWidgets('reading default', (t) async {
      await setUpFunc();
      try {
        await t.pumpWidget(MyApp<String>(preferences, "String2", "", "foo"));
        expect(find.text(""), findsOneWidget);

        await t.pumpWidget(MyApp<bool>(preferences, "bool2", false, false));
        expect(find.text("false"), findsOneWidget);

        await t.pumpWidget(MyApp<int>(preferences, "int2", 0, 100));
        expect(find.text("0"), findsOneWidget);

        await t.pumpWidget(MyApp<double>(preferences, "double2", 1.0, 1000));
        expect(find.text("1.0"), findsOneWidget);

        await t
            .pumpWidget(MyApp<List<String>>(preferences, "List2", [], ["foo"]));
        expect(find.text("[]"), findsOneWidget);

        await t.pumpWidget(MyMapApp(preferences, "EnumType2"));
        expect(find.text('EnumType.type1'), findsOneWidget);

        expect(store.log, <Matcher>[]);
      } finally {
        await tearDown();
      }
    });
  });
}

class FakeSharedPreferencesStore implements SharedPreferencesStorePlatform {
  FakeSharedPreferencesStore(Map<String, Object> data)
      : backend = InMemorySharedPreferencesStore.withData(data);

  final InMemorySharedPreferencesStore backend;
  final List<MethodCall> log = <MethodCall>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> clear() {
    log.add(const MethodCall('clear'));
    return backend.clear();
  }

  @override
  Future<Map<String, Object>> getAll() {
    log.add(const MethodCall('getAll'));
    return backend.getAll();
  }

  @override
  Future<bool> remove(String key) {
    log.add(MethodCall('remove', key));
    return backend.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    log.add(MethodCall('setValue', <dynamic>[valueType, key, value]));
    return backend.setValue(valueType, key, value);
  }
}

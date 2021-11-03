library shared_preferences_flutter_riverpod;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefNotifier<T> extends StateNotifier<T> {
  PrefNotifier(this.prefs, this.prefKey, this.defaultValue)
      : super(prefs.get(prefKey) as T? ?? defaultValue);

  SharedPreferences prefs;
  String prefKey;
  T defaultValue;

  Future<void> update(T value) async {
    if (value is String) {
      await prefs.setString(prefKey, value);
    } else if (value is bool) {
      await prefs.setBool(prefKey, value);
    } else if (value is int) {
      await prefs.setInt(prefKey, value);
    } else if (value is double) {
      await prefs.setDouble(prefKey, value);
    } else if (value is List<String>) {
      await prefs.setStringList(prefKey, value);
    }
    super.state = value;
  }

  @override
  set state(T value) {
    assert(false, 'use update()');
    Future(() async {
      await update(value);
    });
  }
}

StateNotifierProvider<PrefNotifier<T>, T> createPrefProvider<T>({
  required SharedPreferences Function(ProviderReference) prefs,
  required String prefKey,
  required T defaultValue,
}) {
  return StateNotifierProvider<PrefNotifier<T>, T>(
      (ref) => PrefNotifier<T>(prefs(ref), prefKey, defaultValue));
}

class MapPrefNotifier<T> extends StateNotifier<T> {
  MapPrefNotifier(this.prefs, this.prefKey, this.mapFrom, this.mapTo)
      : super(mapFrom(prefs.getString(prefKey)));

  SharedPreferences prefs;
  String prefKey;
  T Function(String?) mapFrom;
  String Function(T) mapTo;

  Future<void> update(T value) async {
    await prefs.setString(prefKey, mapTo(value));
    super.state = value;
  }

  @override
  set state(T value) {
    assert(false, 'use update()');
    Future(() async {
      await update(value);
    });
  }
}

StateNotifierProvider<MapPrefNotifier<T>, T>
    createMapPrefProvider<T>({
  required SharedPreferences Function(ProviderReference) prefs,
  required String prefKey,
  required T Function(String?) mapFrom,
  required String Function(T) mapTo,
}) {
  return StateNotifierProvider<MapPrefNotifier<T>, T>(
      (ref) => MapPrefNotifier<T>(prefs(ref), prefKey, mapFrom, mapTo));
}

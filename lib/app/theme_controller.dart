import 'package:flutter/material.dart';

import '../utils/storage.dart';

/// Preferência de tema escolhida no Perfil.
enum ThemePreference {
  claro('Claro', Icons.light_mode_outlined, ThemeMode.light),
  escuro('Escuro', Icons.dark_mode_outlined, ThemeMode.dark),
  sistema('Sistema', Icons.desktop_windows_outlined, ThemeMode.system);

  const ThemePreference(this.label, this.icon, this.mode);

  final String label;
  final IconData icon;
  final ThemeMode mode;
}

class ThemeController extends ChangeNotifier {
  ThemeController(this._store) : _preference = _read(_store);

  final KeyValueStore _store;
  ThemePreference _preference;

  ThemePreference get preference => _preference;

  set preference(ThemePreference next) {
    if (next == _preference) return;
    _preference = next;
    _store.write(StorageKeys.theme, next.name);
    notifyListeners();
  }

  static ThemePreference _read(KeyValueStore store) {
    final stored = store.read(StorageKeys.theme);
    for (final value in ThemePreference.values) {
      if (value.name == stored) return value;
    }
    return ThemePreference.sistema;
  }
}

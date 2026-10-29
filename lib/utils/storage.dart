import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento chave-valor usado pela API falsa e pelo tema.
///
/// Na web fica no `localStorage`. Em iframes, sandboxes ou modo privado o
/// storage pode estar bloqueado, então tudo cai num fallback em memória.
abstract interface class KeyValueStore {
  String? read(String key);
  void write(String key, String value);
  void remove(String key);
}

/// Chaves usadas pelo app. Os valores ficam em JSON.
abstract final class StorageKeys {
  static const bookings = 'rota:reservas';
  static const profile = 'rota:perfil';
  static const theme = 'rota:tema';

  static const all = {bookings, profile, theme};
}

class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, String>? initial]) : _values = {...?initial};

  final Map<String, String> _values;

  @override
  String? read(String key) => _values[key];

  @override
  void write(String key, String value) => _values[key] = value;

  @override
  void remove(String key) => _values.remove(key);
}

class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  /// Abre o storage do dispositivo. Se ele não estiver disponível, usa memória.
  static Future<KeyValueStore> open() async {
    try {
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(allowList: StorageKeys.all),
      );
      return SharedPreferencesStore._(prefs);
    } catch (error) {
      debugPrint('Storage indisponível, usando memória: $error');
      return MemoryStore();
    }
  }

  @override
  String? read(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void write(String key, String value) {
    // A gravação é assíncrona; uma falha só significa que o dado fica em memória.
    _prefs.setString(key, value).catchError((Object _) {});
  }

  @override
  void remove(String key) {
    _prefs.remove(key).catchError((Object _) {});
  }
}

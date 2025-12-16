// lib/core/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';

/// Storage service using Hive as a replacement for SharedPreferences
/// This provides a similar API but uses Hive which works reliably in APKs
class StorageService {
  static const String _boxName = 'app_storage';
  static Box? _box;

  /// Initialize Hive and open the storage box
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Get a string value from storage
  static String? getString(String key) {
    return _box?.get(key) as String?;
  }

  /// Get a boolean value from storage
  static bool? getBool(String key) {
    return _box?.get(key) as bool?;
  }

  /// Get an integer value from storage
  static int? getInt(String key) {
    return _box?.get(key) as int?;
  }

  /// Get a double value from storage
  static double? getDouble(String key) {
    return _box?.get(key) as double?;
  }

  /// Save a string value to storage
  static Future<void> setString(String key, String value) async {
    await _box?.put(key, value);
  }

  /// Save a boolean value to storage
  static Future<void> setBool(String key, bool value) async {
    await _box?.put(key, value);
  }

  /// Save an integer value to storage
  static Future<void> setInt(String key, int value) async {
    await _box?.put(key, value);
  }

  /// Save a double value to storage
  static Future<void> setDouble(String key, double value) async {
    await _box?.put(key, value);
  }

  /// Remove a value from storage
  static Future<void> remove(String key) async {
    await _box?.delete(key);
  }

  /// Clear all values from storage
  static Future<void> clear() async {
    await _box?.clear();
  }

  /// Check if a key exists in storage
  static bool containsKey(String key) {
    return _box?.containsKey(key) ?? false;
  }

  /// Get all keys in storage
  static List<String> getAllKeys() {
    return _box?.keys.cast<String>().toList() ?? [];
  }
}


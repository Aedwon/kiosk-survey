import 'package:hive_flutter/hive_flutter.dart';

class SurveyRepository {
  static const String _boxName = 'surveysBox';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  Future<void> saveEntry(Map<String, String> entry) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    // Add timestamp if not exists
    if (!entry.containsKey('Timestamp')) {
      entry['Timestamp'] = DateTime.now().toIso8601String();
    }
    await box.add(entry);
  }

  List<Map<String, String>> getAllEntries() {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    return box.values.map((e) => Map<String, String>.from(e)).toList();
  }

  Future<void> clearAll() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    await box.clear();
  }
}

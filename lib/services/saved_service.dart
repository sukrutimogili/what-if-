import 'package:shared_preferences/shared_preferences.dart';

/// Stores bookmarked prompt IDs (most recent first) in SharedPreferences.
class SavedService {
  static const String _key = 'saved_prompt_ids';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  Future<void> save(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }
}

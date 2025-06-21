import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _key = 'tasks';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data != null) {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((json) => Task.fromJson(json)).toList();
    }

    return [];
  }
}

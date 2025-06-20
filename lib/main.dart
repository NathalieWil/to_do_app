import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _addTask() {
    String newTask = _taskController.text.trim();
    if (newTask.isNotEmpty) {
      setState(() {
        _tasks.add({'text': newTask, 'completed': false});
        _taskController.clear();
      });

      _saveTasks();
      print("💾 Tarea agregada: $newTask");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea agregada')));
    }
  }

  void _removeTask(int index) {
    final removed = _tasks[index]['text'];
    setState(() {
      _tasks.removeAt(index);
    });

    _saveTasks();
    print("🗑️ Tarea eliminada: $removed");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_tasks);
    await prefs.setString('tasks', data);
    print("✅ Guardado en shared_preferences: $data");
  }

  void _loadTasks() async {
    print("📥 Intentando cargar tareas...");
    final prefs = await SharedPreferences.getInstance();
    String? taskData = prefs.getString('tasks');

    if (taskData != null) {
      try {
        final decoded = List<Map<String, dynamic>>.from(json.decode(taskData));
        setState(() {
          _tasks.clear();
          _tasks.addAll(decoded);
        });
        print("📦 Tareas cargadas: $decoded");
      } catch (e) {
        print("❌ Error al decodificar tareas: $e");
      }
    } else {
      print("⚠️ No se encontraron tareas guardadas.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tareas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva tarea',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _tasks.isEmpty
                      ? const Center(child: Text('No hay tareas aún'))
                      : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Checkbox(
                                value: task['completed'],
                                onChanged: (value) {
                                  setState(() {
                                    task['completed'] = value!;
                                  });
                                  _saveTasks();
                                  print(
                                    "☑️ Tarea actualizada: ${task['text']} → ${value!}",
                                  );
                                },
                              ),
                              title: Text(
                                task['text'],
                                style: TextStyle(
                                  decoration:
                                      task['completed']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeTask(index),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('darkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(isDarkMode: _isDarkMode, onToggleTheme: _toggleTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final List<Map<String, dynamic>> _recentlyDeleted = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(_tasks));
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(List<Map<String, dynamic>>.from(json.decode(data)));
      });
    }
  }

  void _addTask() {
    final newTask = _taskController.text.trim();
    if (newTask.isNotEmpty) {
      setState(() {
        _tasks.add({'text': newTask, 'completed': false});
        _sortTasks();
        _taskController.clear();
      });
      _saveTasks();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea agregada')));
    }
  }

  void _removeTask(int index) {
    final removedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
    _recentlyDeleted.clear();
    _recentlyDeleted.add(removedTask);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarea eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
              _sortTasks();
              _saveTasks();
            });
          },
        ),
      ),
    );
  }

  void _removeAllTasks() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Eliminar todas las tareas?'),
            content: const Text('Esta acción no se puede deshacer fácilmente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _recentlyDeleted.clear();
        _recentlyDeleted.addAll(_tasks);
        _tasks.clear();
      });
      _saveTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Todas las tareas fueron eliminadas'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () {
              setState(() {
                _tasks.addAll(_recentlyDeleted);
                _sortTasks();
                _saveTasks();
              });
            },
          ),
        ),
      );
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a['completed'] == b['completed']) return 0;
      return a['completed'] ? 1 : -1;
    });
  }

  void _toggleComplete(int index, bool? value) {
    setState(() {
      _tasks[index]['completed'] = value!;
      _sortTasks();
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Eliminar todas',
            onPressed: _tasks.isNotEmpty ? _removeAllTasks : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                        itemBuilder: (_, index) {
                          final task = _tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 2,
                            child: ListTile(
                              leading: Checkbox(
                                value: task['completed'],
                                onChanged:
                                    (value) => _toggleComplete(index, value),
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
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text('¿Eliminar tarea?'),
                                          content: Text(task['text']),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true) _removeTask(index);
                                },
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

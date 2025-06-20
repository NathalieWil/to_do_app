import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/confirm_dialog.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const HomeScreen({super.key, required this.isDark, required this.onToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final StorageService _storage = StorageService();
  List<Task> _lastDeletedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await _storage.loadTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(loaded);
    });
  }

  Future<void> _saveTasks() async {
    await _storage.saveTasks(_tasks);
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _tasks.add(Task(text: text));
      _controller.clear();
      _sortTasks();
    });
    _saveTasks();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tarea agregada')));
  }

  void _deleteTask(int index) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmación',
      content: '¿Eliminar esta tarea?',
    );

    if (confirm != true) return;

    final deleted = _tasks.removeAt(index);
    _lastDeletedTasks = [deleted];
    setState(() {});
    _saveTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarea eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              _tasks.insert(index, deleted);
              _sortTasks();
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  void _deleteAllTasks() async {
    if (_tasks.isEmpty) return;

    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmación',
      content: '¿Eliminar todas las tareas?',
    );

    if (confirm != true) return;

    _lastDeletedTasks = List<Task>.from(_tasks);
    setState(() => _tasks.clear());
    _saveTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Todas las tareas eliminadas'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              _tasks.addAll(_lastDeletedTasks);
              _sortTasks();
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  void _toggleComplete(int index, bool? value) {
    setState(() {
      _tasks[index].completed = value ?? false;
      _sortTasks();
    });
    _saveTasks();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.completed == b.completed) return 0;
      return a.completed ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        centerTitle: true,
        actions: [
          ThemeToggle(isDark: widget.isDark, onToggle: widget.onToggle),
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
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nueva tarea',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
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
                      ? const Center(child: Text('No hay tareas'))
                      : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (_, i) {
                          final task = _tasks[i];
                          return TaskTile(
                            task: task,
                            onToggle: (val) => _toggleComplete(i, val),
                            onDelete: () => _deleteTask(i),
                          );
                        },
                      ),
            ),
            if (_tasks.isNotEmpty)
              TextButton.icon(
                onPressed: _deleteAllTasks,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Eliminar todas',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

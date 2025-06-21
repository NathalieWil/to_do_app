import 'package:flutter/material.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/task_tile.dart';
import '../services/storage_service.dart';
import '../models/task.dart';

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
  List<Task> _lastDeletedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loaded = await StorageService().loadTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(loaded);
    });
  }

  Future<void> _saveTasks() async {
    await StorageService().saveTasks(_tasks);
  }

  void _addTask() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _tasks.add(Task(text: text));
      _sortTasks();
      _controller.clear();
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
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addTask(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _tasks.isEmpty
                      ? const Center(child: Text('No hay tareas'))
                      : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder:
                            (_, i) => TaskTile(
                              task: _tasks[i],
                              onDelete: () => _deleteTask(i),
                              onToggle: (val) => _toggleComplete(i, val),
                            ),
                      ),
            ),
            if (_tasks.isNotEmpty)
              TextButton.icon(
                onPressed: _deleteAllTasks,
                icon: Icon(Icons.delete_forever),
                label: const Text('Eliminar todas'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

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

  void _addTask() {
    String newTask = _taskController.text.trim();
    if (newTask.isNotEmpty) {
      setState(() {
        _tasks.add({'text': newTask, 'completed': false});
        _taskController.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea agregada')));
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tareas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto y botón
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

            // Lista de tareas
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

class Task {
  final String text;
  bool completed;

  Task({required this.text, this.completed = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(text: json['text'], completed: json['completed'] ?? false);
  }

  Map<String, dynamic> toJson() => {'text': text, 'completed': completed};
}

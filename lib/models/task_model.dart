class Task {
  final int? id;
  final String subject;
  final String topic;
  final String revision;
  final String nextRevisionDate;
  final bool isDone;

  Task({
    this.id,
    required this.subject,
    required this.topic,
    required this.revision,
    required this.nextRevisionDate,
    required this.isDone,
  });

  // Convert a Task object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'revision': revision,
      'nextRevisionDate': nextRevisionDate,
      'isDone': isDone ? 1 : 0, // SQLite doesn't have a boolean type (0=false, 1=true)
    };
  }

  // Create a Task object from a Map object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      subject: map['subject'],
      topic: map['topic'],
      revision: map['revision'],
      nextRevisionDate: map['nextRevisionDate'],
      isDone: map['isDone'] == 1,
    );
  }
}

class Task {
  final int? id;
  final String subject;
  final String topic;
  int readingStage; // पहले 'revision' (String) था, अब 'readingStage' (int) है
  DateTime nextRevisionDate;
  String status; // 'pending', 'completed_today', etc.

  Task({
    this.id,
    required this.subject,
    required this.topic,
    this.readingStage = 1,
    required this.nextRevisionDate,
    this.status = 'pending',
  });

  // डेटाबेस में सेव करने के लिए Map में बदलना
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'readingStage': readingStage,
      // DateTime को स्ट्रिंग में सेव करेंगे (ISO 8601 format)
      'nextRevisionDate': nextRevisionDate.toIso8601String(),
      'status': status,
    };
  }

  // डेटाबेस से आए Map को Task ऑब्जेक्ट में बदलना
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      subject: map['subject'],
      topic: map['topic'],
      readingStage: map['readingStage'],
      // स्ट्रिंग को वापस DateTime में बदलेंगे
      nextRevisionDate: DateTime.parse(map['nextRevisionDate']),
      status: map['status'],
    );
  }
}

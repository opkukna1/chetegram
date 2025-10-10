class Flashcard {
  final int? id;
  final String subject;
  final String topic;
  final String frontText;
  final String backText;
  final String colorHex;

  Flashcard({
    this.id,
    required this.subject,
    required this.topic,
    required this.frontText,
    required this.backText,
    required this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'frontText': frontText,
      'backText': backText,
      'colorHex': colorHex,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      subject: map['subject'],
      topic: map['topic'],
      frontText: map['frontText'],
      backText: map['backText'],
      colorHex: map['colorHex'],
    );
  }
}

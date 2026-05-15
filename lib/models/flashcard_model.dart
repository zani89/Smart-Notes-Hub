class FlashcardModel {
  final String id;
  final String noteId;
  final String question;
  final String answer;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReview;

  FlashcardModel({
    required this.id,
    required this.noteId,
    required this.question,
    required this.answer,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    required this.nextReview,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'],
      noteId: json['note_id'],
      question: json['question'],
      answer: json['answer'],
      easeFactor: (json['ease_factor'] ?? 2.5).toDouble(),
      interval: json['interval'] ?? 0,
      repetitions: json['repetitions'] ?? 0,
      nextReview: DateTime.parse(json['next_review'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note_id': noteId,
      'question': question,
      'answer': answer,
      'ease_factor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'next_review': nextReview.toIso8601String(),
    };
  }
}

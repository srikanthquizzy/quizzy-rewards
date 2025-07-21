class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;
  final String difficulty;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int coinsEarned;
  final DateTime completedAt;
  final List<bool> answers;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.coinsEarned,
    required this.completedAt,
    required this.answers,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      coinsEarned: map['coinsEarned'] ?? 0,
      completedAt: DateTime.parse(map['completedAt'] ?? DateTime.now().toIso8601String()),
      answers: List<bool>.from(map['answers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'coinsEarned': coinsEarned,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers,
    };
  }

  double get percentage => (correctAnswers / totalQuestions) * 100;
}
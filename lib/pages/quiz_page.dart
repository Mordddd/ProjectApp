import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/option_tile.dart';
import '../widgets/custom_button.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> quizzes;
  int currentQuestionIndex = 0;
  Set<int> selectedIndices = {};
  bool hasAnswered = false;
  int correctCount = 0;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    quizzes = [
      // Single Answer Question
      const Question(
        questionText: 'Apa ibukota Indonesia?',
        options: ['Surabaya', 'Bandung', 'Jakarta', 'Medan', 'Yogyakarta'],
        correctAnswerIndices: [2],
        isMultipleAnswer: false,
      ),
      // Multiple Answer Question
      const Question(
        questionText:
            'Manakah yang termasuk bahasa pemrograman? (Pilih lebih dari satu)',
        options: ['Python', 'SQL', 'JavaScript', 'HTML', 'Excel'],
        correctAnswerIndices: [0, 1, 2],
        isMultipleAnswer: true,
      ),
      // Single Answer Question
      const Question(
        questionText: 'Berapa hasil dari 15 + 8 - 3?',
        options: ['18', '20', '22', '25', '30'],
        correctAnswerIndices: [2],
        isMultipleAnswer: false,
      ),
      // Multiple Answer Question
      const Question(
        questionText:
            'Negara-negara di Asia Tenggara adalah? (Pilih lebih dari satu)',
        options: ['Thailand', 'Jepang', 'Vietnam', 'Belanda', 'Malaysia'],
        correctAnswerIndices: [0, 2, 4],
        isMultipleAnswer: true,
      ),
      // Single Answer Question
      const Question(
        questionText: 'Siapa penemu pesawat terbang?',
        options: [
          'George Washington',
          'Wright Brothers',
          'Thomas Edison',
          'Isaac Newton',
          'Albert Einstein',
        ],
        correctAnswerIndices: [1],
        isMultipleAnswer: false,
      ),
    ];
    totalCount = quizzes.length;
  }

  void _selectAnswer(int index) {
    if (hasAnswered) return;

    final question = quizzes[currentQuestionIndex];

    if (question.isMultipleAnswer) {
      // Multiple choice: toggle selection
      setState(() {
        if (selectedIndices.contains(index)) {
          selectedIndices.remove(index);
        } else {
          selectedIndices.add(index);
        }
      });
    } else {
      // Single choice: immediate feedback
      setState(() {
        selectedIndices = {index};
        hasAnswered = true;
        if (question.correctAnswerIndices.contains(index)) {
          correctCount++;
        }
      });
    }
  }

  void _submitMultipleAnswer() {
    if (hasAnswered || selectedIndices.isEmpty) return;

    final question = quizzes[currentQuestionIndex];

    setState(() {
      hasAnswered = true;
      if (question.checkAnswer(selectedIndices.toList())) {
        correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quizzes.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedIndices = {};
        hasAnswered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedIndices = {};
      hasAnswered = false;
      correctCount = 0;
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$correctCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((correctCount / totalCount) * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              correctCount >= totalCount * 0.7
                  ? '🎉 Bagus sekali!'
                  : '📚 Terus belajar!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: const Text('Ulangi'),
          ),
        ],
      ),
    );
  }

  OptionState _getOptionState(int index, Question question) {
    if (!hasAnswered) {
      if (question.isMultipleAnswer && selectedIndices.contains(index)) {
        return OptionState.selected;
      }
      return OptionState.normal;
    }

    // After answered
    if (question.correctAnswerIndices.contains(index)) {
      return OptionState.correct;
    }

    if (selectedIndices.contains(index)) {
      return OptionState.incorrect;
    }

    return OptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final question = quizzes[currentQuestionIndex];
    final isAnswered = hasAnswered;
    final isCorrect =
        isAnswered && question.checkAnswer(selectedIndices.toList());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quiz'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Header
            Card(
              color: question.isMultipleAnswer
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF6366F1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        question.isMultipleAnswer
                            ? Icons.done_all_rounded
                            : Icons.radio_button_checked,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.isMultipleAnswer
                                ? 'Multiple Answer Quiz'
                                : 'Single Answer Quiz',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question.isMultipleAnswer
                                ? 'Pilih semua jawaban yang benar'
                                : 'Pilih satu jawaban yang benar',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${currentQuestionIndex + 1}/$totalCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / totalCount,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            question.isMultipleAnswer
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${((currentQuestionIndex + 1) / totalCount * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: question.isMultipleAnswer
                            ? const Color(0xFFFEF08A)
                            : const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        question.isMultipleAnswer
                            ? 'Pilihan Ganda Jamak'
                            : 'Pilihan Ganda Tunggal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: question.isMultipleAnswer
                              ? const Color(0xFFB45309)
                              : const Color(0xFF6366F1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      question.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(question.options.length, (index) {
                      return OptionTile(
                        text: question.options[index],
                        state: _getOptionState(index, question),
                        isMultiSelect: question.isMultipleAnswer,
                        isSelected: selectedIndices.contains(index),
                        onTap: () => _selectAnswer(index),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Result Card (for single answer - immediate feedback)
            if (isAnswered && !question.isMultipleAnswer)
              Card(
                color: isCorrect
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCorrect ? 'Benar! ✅' : 'Salah! ❌',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Jawaban benar: ${question.getCorrectAnswersText()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Result Card (for multiple answer - after submit)
            if (isAnswered && question.isMultipleAnswer)
              Card(
                color: isCorrect
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCorrect ? 'Benar! ✅' : 'Salah! ❌',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jawaban benar: ${question.getCorrectAnswersText()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isCorrect
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Submit Button (for multiple answer only)
            if (!isAnswered && question.isMultipleAnswer)
              CustomButton(
                text: selectedIndices.isEmpty
                    ? 'Pilih jawaban'
                    : 'Submit Jawaban',
                icon: Icons.check_rounded,
                onPressed: () {
                  if (selectedIndices.isNotEmpty) {
                    _submitMultipleAnswer();
                  }
                },
                width: double.infinity,
              ),

            // Next Button
            if (isAnswered)
              CustomButton(
                text: currentQuestionIndex == quizzes.length - 1
                    ? 'Lihat Hasil'
                    : 'Soal Berikutnya',
                icon: Icons.arrow_forward_rounded,
                onPressed: _nextQuestion,
                width: double.infinity,
              ),
          ],
        ),
      ),
    );
  }
}
